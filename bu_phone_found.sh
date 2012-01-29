#!/bin/sh

unload_0() {
  phone_id=$(zenity --entry \
      --title="ODK phone was found" \
      --text="Enter phone ID (or press cancel to ignore):")
  if [ $? = 0 ]; then
    unload_1 $phone_id
  else
    cancel_cronjob
  fi
}

unload_1() {
  # we know the user wants to proceed
  options=$(zenity --list \
      --text "Select options" \
      --checklist \
      --column "Active" --column "Option" \
      TRUE "Remove from ODK" TRUE "Preserve backup" \
      TRUE "Unmount on completion")
  unload_2 "$phone_id" "$options"
}

UNLOAD_PYSCRIPT_PATH="`which python` $FORMHUB_BIN_DIR/data_unloader/unload_from_phone.py "

unload_2() {
  phone_id=$1
  search_str=$2
  flag_str="--phone-id=$phone_id --drive-path=$drive_path"
  build_flagstr "Remove from ODK" "--remove-instances"
  build_flagstr "Preserve backup on sdcard" "--preserve-on-sdcard"
#  build_flagstr "Unmount" "--unmount-drive"
  results=$($UNLOAD_PYSCRIPT_PATH --phone-id=$phone_id \
        --drive-path=$drive_path $flag_str -D)
  echo "$search_str" | grep "Unmount" > /dev/null
  if [ $? = 0 ]; then
    unmount_results=$(bu_unmount_odk_drive.sh $drive_path)
    results="$results\n\n$unmount_results"
  fi
  echo "results: $results"
}

build_flagstr() {
  param=$1
  flag=$2
  echo "$search_str" | grep "$param" > /dev/null
  if [ $? = 0 ]; then
    flag_str="$flag_str $flag"
  fi
}

cancel_cronjob() {
  # the cronjob will continue to bug the user...
  # TODO: cancel the behavior somehow
#  export IGNORE_ODK=1
  echo "Cancelling"
}

drive_path=$1

unload_0

