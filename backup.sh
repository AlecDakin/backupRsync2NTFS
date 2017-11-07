#!/bin/bash

# Needs telegram-send installed to make use of Telegram messaging
DIRLOC=/media/usb0
BACKUPLOC=$DIRLOC/backup/backup_$(date +%Y-%m-%d)
LOGLOC=$DIRLOC/logs/backup_$(date +%Y-%m-%d).log
USBDRIVE="$( cat /etc/mtab | grep $DIRLOC | wc -l )"

if [ "$USBDRIVE" -eq 1 ]; then
        # Run the rsync
        rsync -brtvhP --modify-window=2 --stats --delete-delay --force --log-file=$LOGLOC --backup-dir=$BACKUPLOC /storage/ $DIRLOC/live/
	#sync to flush writes to USB device
	sync
	#echo $DIRLOC $USBDRIVE
	telegram-send -g "Backup complete, see attached log"
	telegram-send -g -f $LOGLOC
else 
	telegram-send -g "*** No USB drive attached for Backup ***"
fi

