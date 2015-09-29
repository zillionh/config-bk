gdb -batch -x gdb-profile -n /sw/unicorn/bin/web-engine `pidof web-engine` 2>&1 >> gdbprof.`date +%Y-%m-%d.%H.%M.%S`.log
