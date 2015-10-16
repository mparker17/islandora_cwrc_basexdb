#!/bin/bash
DATADIR="/var/basex/BaseXData/"
LOGDIR="/var/basex/BaseXData/.logs"
LOGFILE="$LOGDIR/backup_`date +%Y-%m-%d`"
HOSTNAME="localhost"
PORT="1984"

#path to the file containing the username and password
# file should contain one line with the username and password
# separated by a whitespace character
USERFILE="/home/jefferya/dev/userkey"

export PATH=$PATH:/usr/bin

# check that backup dir exists
if [ ! -d $LOGDIR ]; then
        mkdir $LOGDIR
fi


read -r USERNAME PASSWORD <<< $( cat $USERFILE )

basexclient -n $HOSTNAME -p $PORT -U $USERNAME -P $PASSWORD -c "CREATE BACKUP * " >> $LOGFILE 2>&1

date "+%Y-%m-%d %H:%M:%S %Z" >> $LOGFILE 2>&1

exit 0
