#!/bin/bash
### check_tomcat_sessions Troy Watson 2016
### cmdline-jmxclient.jar is available from http://crawler.archive.org/cmdline-jmxclient/
cmdLineJMXJar=./cmdline-jmxclient.jar
user=admin
password=password
jmxHost=$1
port=9999
HOST_SHORT=`echo $1 | awk -F '.' '{print $1}'`
RESULT=$(java -jar ${cmdLineJMXJar} ${user}:${password} ${jmxHost}:${port} Catalina:type=Manager,context=/apps,host=localhost listSessionIds 2>&1)
total=$(echo $RESULT | tr ' ' '\n' | wc -l)
#remove noise from tomcat
total=$(($total-6))
#only count sessions pinned to specified host
local_sessions=$(echo $RESULT | tr ' ' '\n' | grep $HOST_SHORT | wc -l)
echo $RESULT | tr ' ' '\n' | grep $HOST_SHORT
printf "\nSessions: $total,$local_sessions\n"

