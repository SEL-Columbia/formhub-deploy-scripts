IP_ADDR=$(ifconfig | grep "192.168" | cut -c 21-34)
if [ $? = 0 ]; then
  IP_TEXT="Your IP Address is $IP_ADDR"
else
  IP_TEXT="Your IP was not found. Try running 'ifconfig'"
fi

zenity --info --text="$IP_TEXT"
