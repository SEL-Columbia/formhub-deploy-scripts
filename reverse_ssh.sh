#!/bin/bash

# crontab -e on childcount user
# on childcount host.
#
# MAILTO=""
# # reverse ssh tunnel keep-alive
# */3 * * * * /bin/bash /usr/bin/reverse_ssh >/dev/null 2>&1

#COMMAND="ssh -N -f -R linode.mvpafrica.org:2210:localhost:22 linode.mvpafrica.org"
#ps ax |grep "$COMMAND" |grep -v "grep" > /dev/null 2>&1 || $COMMAND > /dev/null 2>&1

createTunnel() {
    PORT_NUMBER=$1
    ssh -N -f -R linode.mvpafrica.org:$PORT_NUMBER:localhost:22 -L19922:linode.mvpafrica.org:22 formhub@linode.mvpafrica.org
    if [[ $? -eq 0 ]]; then
        echo SSH tunnel created successfully
    else
        echo An error occurred creating SSH tunnel: $?
    fi
}
## Run the 'ls' command remotely.  If it returns non-zero, then create a new connection
/usr/bin/ssh -p 19922 formhub@localhost ls
if [ $? -ne 0 ]; then
    PORT_NUMBER=$(curl --silent http://linode.mvpafrica.org:8090/get_a_port?$UNIQUE_ID)
    if [ $PORT_NUMBER -ne -1 ]; then
        echo Creating new tunnel connection
        createTunnel $PORT_NUMBER
    fi
fi

