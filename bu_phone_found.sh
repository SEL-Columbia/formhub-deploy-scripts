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

UNLOAD_PYSCRIPT_PATH="`which python` ~/pyscript.py "

unload_2() {
  phone_id=$1
  search_str=$2
  flag_str="--phone-id=$phone_id"
  build_flagstr "Remove from ODK" "--remove"
  build_flagstr "Preserve backup on sdcard" "--backup"
  build_flagstr "Unmount" "--unmount"
  $UNLOAD_PYSCRIPT_PATH$flag_str
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
  export IGNORE_ODK=1
  echo "Cancelling"
}

unload_0

