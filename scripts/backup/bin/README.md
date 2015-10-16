Automating the backup of BaseX DB

Setup:
--
* Create the directory: /var/basex/backup/bin
* Create the directory: /var/basex/backup/backup.daily
* Create the directory: /var/basex/backup/bin/backup.monthly
* Create the directory: /var/basex/backup/bin/backup.weekly
* populate "bin" with the contents of the GitHub repo
* sudo ln -s /var/basex/backup/bin/basex_backup.cron /etc/cron.d/basex_backup.cron



backup_basex.sh
-
* script handling the backup

userkey
-
file containing the username/password to execute the backup
* do not add to the GitHub repo
* username password on one line

backup_basex_rotate.sh
-
* script to rotate the backup files out of the data directory

basex_backup.cron
-
* cron job to run the backup and rotate
* setup
 * sudo ln -s /var/basex/backup/bin/basex_backup.cron /etc/cron.d/basex_backup.cron



