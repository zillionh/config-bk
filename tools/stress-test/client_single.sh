#!/bin/sh

count=0

while [ 1 ]; do 
if [ $count == 0 ]; then
    url=`cat /proc/sys/kernel/random/uuid`
fi
echo $url
curl "http://traffic-server-edge2.test.ipcdn.cisco.com/infinite/""$url" -o /dev/null;
tmp=$[$count+1]
count=$[$tmp%5]
sleep $(( ( RANDOM % 5 )  + 1 ))
done
