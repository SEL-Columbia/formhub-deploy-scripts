export UNIQUE_ID=`ifconfig | grep ether | head -n1 | md5sum | cut -c 1-5`
SCRIPT_PATH=`readlink -f $0`
export FORMHUB_BIN_DIR=$(dirname "$SCRIPT_PATH")
export PATH="$PATH:$FORMHUB_BIN_DIR"
export AUTOLAUNCH_ODK_UNLOADER=1
