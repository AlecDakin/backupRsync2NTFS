#!/bin/bash

# Needs telegram-send installed to make use of Telegram messaging
DIRLOC=/media/usb0
BACKUPLOC=$DIRLOC/backup/backup_$(date +%Y-%m-%d)
LOGLOC=$DIRLOC/logs/backup_$(date +%Y-%m-%d).log
USBDRIVE="$( cat /etc/mtab | grep $DIRLOC | wc -l )"

if [ "$USBDRIVE" -eq 1 ]; then
	# delete old logs and backups - more than 90 days
	find $DIRLOC/logs/*.log -mtime +90 -type f -delete
	find $DIRLOC/backup/backup* -mtime +90 -type d -ls -exec rm -rv {} +
	# sync the home directory to storage, so it also gets backed up
	rsync -brtvhP /home/ /storage/home/
        # Run the rsync
        rsync -brtvhP --modify-window=2 --stats --delete-delay --delete-excluded --force --exclude=spool --exclude="*.tmp" --exclude="*~$*" --log-file=$LOGLOC --backup-dir=$BACKUPLOC /storage/ $DIRLOC/live/
	#sync to flush writes to USB device
	sync
	echo $DIRLOC $USBDRIVE
	telegram-send -g "$(hostname) Backup complete, see attached log"
	if [ ! -f "$LOGLOC" ]; then
		telegram-send -g "$(hostname)  *** ERROR NO BACKUP LOG ***"
	else
		telegram-send -g "$(hostname)" -f "$LOGLOC"
	fi
else
	telegram-send -g "$(hostname) *** No USB drive attached for Backup ***"
fi
