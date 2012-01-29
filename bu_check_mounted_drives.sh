#!/bin/sh

check_for_odk() {
  drive=$1
  odk_drive_count=`ls "$1" | egrep ^odk$ | wc -l`
  if [ $odk_drive_count != 0 ]; then
    instance_count=`ls "$drive/odk/instances" | wc -l`
    if [ $instance_count -gt 0 ]; then
      sh bu_phone_found.sh "$1"
    fi
  fi
}

check_for_mounted_drives() {
  mounted_drives=`mount -l | grep /media | wc -l`
  if [ $mounted_drives != 0 ]; then
    for drive in `ls /media`
    do
      check_for_odk "/media/$drive"
    done
  fi
}

if [ $AUTOLAUNCH_ODK_UNLOADER = 1 ]; then
  check_for_mounted_drives
fi

