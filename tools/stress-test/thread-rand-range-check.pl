#! /usr/bin/perl -wl

use POSIX ":sys_wait_h";
use threads;
use threads::shared;
use Thread::Queue;

$os_url = "http://10.79.53.207/infinite/";
$cdn_url = "http://ucs220-de-4-se-2.se.arch.com/infinite/";
@cmd_line_base = ("curl", "-s", "--header", "\"Range: bytes=7100-8400\"", $cdn_url, "-o", "/dev/null", "--retry", "10", "-w", "\"%{http_code}\"");

$sleep_seconds = 5;
$num_workers = 96;
$num_clients_per_url = 6;
my $loop :shared = 1;

$SIG{INT} = sub { $loop = 0; print "$$: caught a signal $!, exiting!"; };

my $stat_urls_done :shared = 0;
my $stat_clients_ok :shared = 0;
my $stat_clients_bad :shared = 0;
my $stat_clients_fail :shared = 0;

sub update_stat {
    $flag = shift;
    if ($flag == 0) {
        $stat_urls_done++;
    }
    elsif ($flag == 1) {
        $stat_clients_ok++;
    }
    elsif ($flag == 2) {
        $stat_clients_bad++;
    }
    elsif ($flag == 3) {
        $stat_clients_fail++;
    }
}

sub report_stat {
    print "==============================";
    print "URls done:    $stat_urls_done";
    print "Clients OK:   $stat_clients_ok";
    print "Clients KO:   $stat_clients_bad";
    print "Clients Fail: $stat_clients_fail";
    my $left = $DataQueue->pending();
    print "Clients Pending: $left";
}

sub if_use_range{
    return int(rand($num_clients_per_url*2));
}

sub get_range{
    my $a = 0;
    $a = int(rand(100000)) if &if_use_range;
    my $b = int(rand(100000));
    return ($a, $b) if $a < $b;
    return ($b, $a)
}

sub request_url {
    my $range = shift;
    my $my_url = shift;
    my $file_save_name = shift;

    my @cmd_line = @cmd_line_base;
    $cmd_line[3] = sprintf "%s", $range;
    $cmd_line[4] = sprintf "%s", $my_url;
    $cmd_line[6] = sprintf "%s", $file_save_name;

    #print join(" ", @cmd_line);
    return readpipe(join(" ", @cmd_line));
}

sub client_check {
    my $rand_id = shift;

    my($a, $b) = &get_range;
    my $range = sprintf "\"Range: bytes=%d-%d\"", $a, $b;

# request url from CDN
    my $url = sprintf "%s%s", $cdn_url, $rand_id;
    my $cdn_file_name = sprintf "/tmp/%s.%d-%d.cdn", $rand_id, $a, $b;
    my $cdn_http_resp = &request_url($range, $url, $cdn_file_name);

# request url from OS
    $url = sprintf "%s%s", $os_url, $rand_id;
    my $os_file_name = sprintf "/tmp/%s.%d-%d.os", $rand_id, $a, $b;
    my $os_http_resp = &request_url($range, $url, $os_file_name);

# check md5 sum
    my $del_file = 1;
    if ( $cdn_http_resp =~ /20\d/ && $os_http_resp =~ /20\d/ ){
        if ( ! -e $cdn_file_name ) 
        {
            print "$$: ---file $cdn_file_name not downloaded---" ;
            &update_stat(3);
        }
        elsif ( ! -e $os_file_name ) {
            print "$$: ---file $os_file_name not downloaded---" ;
            &update_stat(3);
        }
        else {
            my @md5s = readpipe("md5sum $cdn_file_name $os_file_name");
            my ($md5_cdn, undef) = split /\s+/, $md5s[0];
            my ($md5_os, undef) = split /\s+/, $md5s[1];
            if ($md5_cdn eq $md5_os) {
                &update_stat(1);
            }
            else {
                print "$$: md5sum not match for $cdn_file_name ($cdn_http_resp) and $os_file_name ($os_http_resp)" ;
                &update_stat(2);
                #$del_file = 0;
            }
        }
    }
    else {
        print "$$: !!!cdn return: $cdn_http_resp\t\tos return: $os_http_resp!!!";
        &update_stat(3);
    }
    system("rm -f $cdn_file_name $os_file_name") if $del_file;
}

sub client_thread {
    while (my $rand_id = $DataQueue->dequeue()) {
        &client_check($rand_id);
        last if ($loop == 0);
    }
}

sub create_url_for_clients {
    return if $DataQueue->pending() > ($num_workers * $num_clients_per_url) * $sleep_seconds;
    my @rand_ids;
    for(my $i = 1; $i <= $num_workers; $i++ ) {
        open my $FILE_RANDID, "/proc/sys/kernel/random/uuid";
        my $rand_id= <$FILE_RANDID>;
        chomp($rand_id);
        close $FILE_RANDID;

        for(my $j = 1; $j <= $num_clients_per_url; $j++ )
        {
           push @rand_ids, $rand_id;
        }
        &update_stat(0);
    }
    $DataQueue->enqueue(@rand_ids);
}

$DataQueue = Thread::Queue->new();

# Create worker threads
for(my $i = 1; $i <= $num_workers; $i++ ) {
    my $thr = threads->create(\&client_thread);
    unshift @threads, $thr;
}

do {
    &create_url_for_clients;
    sleep($sleep_seconds);
    &report_stat;
} while($loop);

# Clean up queue
$DataQueue->dequeue($left) if $left = $DataQueue->pending();

# Notify all pending threads
for(my $i = 1; $i <= $num_workers; $i++ ) {
    $DataQueue->enqueue(undef);
}

# Wait threads terminate
while(my $thr = shift @threads) {
    $thr->join();
}
