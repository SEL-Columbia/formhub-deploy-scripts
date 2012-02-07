export UNIQUE_ID=`ifconfig | grep HWaddr | grep eth1 | egrep -o "..:..:..:..:..:.." | md5sum | cut -c1-6`
SCRIPT_PATH=`readlink -f $0`
export FORMHUB_BIN_DIR=$(dirname "$SCRIPT_PATH")
export PATH="$PATH:$FORMHUB_BIN_DIR"
export AUTOLAUNCH_ODK_UNLOADER=1
