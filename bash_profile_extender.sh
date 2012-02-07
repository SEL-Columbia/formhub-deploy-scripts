if [ ! -f ~/.formhub_unique_id ]; then
  echo `ifconfig | grep HWaddr | egrep -o "..:..:..:..:..:.." | md5sum | cut -c1-6` > ~/.formhub_unique_id
fi
export UNIQUE_ID=`cat ~/.formhub_unique_id`
SCRIPT_PATH=`readlink -f $0`
export FORMHUB_BIN_DIR=$(dirname "$SCRIPT_PATH")
export PATH="$PATH:$FORMHUB_BIN_DIR"
export AUTOLAUNCH_ODK_UNLOADER=1
