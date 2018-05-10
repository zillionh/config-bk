#!/bin/sh


exiting=0

trap 'echo "singal received, exiting ...";exiting=1' INT TERM

count=$1
i=0
interval=5

while [ $i -lt $count ]; do 

	./client_single.sh > /dev/null 2>&1 &
	i=`expr $i + 1`

done

while [ 1 ]; do
	if [ $exiting == "1" ]; then
		echo "signal received, exiting ..."
		kill -9 `ps -ef | grep single | awk '{print $2}' | tr '\r\n' ' '`
		sleep 3
	fi
	echo "Active clients:"
	echo "------------------------------------"
	ps -ef | egrep "curl|single" | awk '{out=$8; for(i=9;i<=NF;i++){out=out" "$i}; print out}' | sort | uniq -c
	echo "------------------------------------"
	if [ $exiting == "1" ]; then
		exit 0
	fi

	echo "sleep $interval"
	sleep $interval
done



