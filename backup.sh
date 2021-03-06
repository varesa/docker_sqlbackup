#!/bin/bash

date=$(date +%Y_%m_%d)

if [ -f /root/.ssh/id_rsa ]
then
	echo "Creating backups for $date"
	mkdir $date
	mysql -u$DB_USER -p$DB_PASSWORD -h$DB_HOST -N -e 'show databases' | while read dbname
	do
		echo "Dumping database $dbname"
		mysqldump -u"$DB_USER" -p"$DB_PASSWORD" -h$DB_HOST "$dbname" > "$date/$dbname".sql
	done
	echo "Copying backups to $TARGET"
	rsync -va $date $TARGET
	echo "Done, cleaning up"
	rm -rf ./$date
else
	echo "Please create SSH keys and copy them to the backup target"
	if [ -t 1 ]
	then
		ssh-keygen
		host=$(echo $TARGET | sed "s/\(.*\):.*/\1/")
		ssh-copy-id $host
	fi
fi
