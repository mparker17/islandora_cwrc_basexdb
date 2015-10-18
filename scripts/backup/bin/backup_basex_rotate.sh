#!/bin/bash
# Original version by Julius Zaromskis
# tweaked for CWRC's specific requirments
# Backup rotation
# https://nicaw.wordpress.com/2013/04/18/bash-backup-rotation-script/

# Storage folder where to move backup files
# Must contain backup.monthly backup.weekly backup.daily folders
storage=/var/basex/backup

# Source folder where files are backed
source=$storage/../BaseXData

# Destination file names
#date_daily=`date +"%d-%m-%Y"`
#date_weekly=`date +"%V sav. %m-%Y"`
#date_monthly=`date +"%m-%Y"`

# Get current month and week day number
month_day=`date +"%d"`
week_day=`date +"%u"`

# Optional check if source files exist. Email if failed.
#if [ ! -f $source/archive.tgz ]; then
#ls -l $source/ | mail your@email.com -s "[backup script] Daily backup failed! Please check for missing files."
#fi

# It is logical to run this script daily. We take files from source folder and move them to
# appropriate destination folder

# On first month day do
if [ "$month_day" -eq 1 ] ; then
  destination=$storage/backup.monthly
else
  # On saturdays do
  if [ "$week_day" -eq 6 ] ; then
    destination=$storage/backup.weekly
  else
    # On any regular day do
    destination=$storage/backup.daily
  fi
fi

# Move the files
if [ ! -d "$destination" ]; then
  mkdir $destination
fi

mv -v $source/*.zip $destination

# daily - keep for 14 days
find $storage/backup.daily/ -maxdepth 1 -mtime +14 -type d -exec rm -rv {} \;

# weekly - keep for 60 days
find $storage/backup.weekly/ -maxdepth 1 -mtime +60 -type d -exec rm -rv {} \;

# monthly - keep for 300 days
find $storage/backup.monthly/ -maxdepth 1 -mtime +300 -type d -exec rm -rv {} \;
