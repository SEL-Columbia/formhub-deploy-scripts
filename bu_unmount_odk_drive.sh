#!/bin/sh

odk_drive=$1

#check to see if it's actually an odk drive?

umount $odk_drive
if [ $? = 2 ]; then
  echo "There was an error unmounting the drive"
else
  echo "Your drive was unmounted."
fi

