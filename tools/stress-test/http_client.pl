#! /usr/bin/perl -wl

use LWP::UserAgent;

my $client = LWP::UserAgent->new( keep_alive => 1 );
push(@LWP::Protocol::http::EXTRA_SOCK_OPTS, SendTE => 0); #disable "TE" Header
$client->timeout(600);
$client->requests_redirectable(undef); #not follow 302

while(<>)
{
    chomp;
    #my $req = HTTP::Request->new(GET => $_);
    my $url = $_;
    my $resp = $client->get($url);
    #print $resp->status_line;
}
