#!/bin/sh

myemail=$1
if [ -n "$myemail" ] ; then
	mycrontmp=/root/cron.tmp.$$
	# get current user list
	for i in `cat /etc/passwd | cut -f1 -d :`; do
		echo "--------------------------------------------------"
		echo "Username: ${i}"
		echo "--------------------------------------------------"
		crontab -u ${i} -l 2>&1
		echo "--------------------------------------------------"
	done > $mycrontmp
	cat $mycrontmp | mail -s "crontab report for `hostname`" ${myemail}
	rm -f $mycrontmp
else
	echo "Please supply a valid email address to get the report."
	exit
fi
