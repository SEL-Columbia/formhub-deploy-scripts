export UNIQUE_ID=`ifconfig | grep ether | head -n1 | md5sum | cut -c 1-5`

export PATH="$PATH:/home/formhub/bin"
