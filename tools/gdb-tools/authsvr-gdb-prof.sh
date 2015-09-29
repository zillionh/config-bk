gdb -batch -x gdb-profile -n /sw/unicorn/bin/CdsAuthServer `pidof CdsAuthServer` 2>&1 >> authsvr.gdbprof.`date +%Y-%m-%d.%H.%M.%S`.log
