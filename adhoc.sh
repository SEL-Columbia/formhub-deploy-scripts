# stop net manager and bring interfacer down
sudo service network-manager start
sudo service network-manager stop
sudo ip link set eth1 down
# switch card into ad-hoc mode
sudo iwconfig eth1 mode ad-hoc
# set channel
sudo iwconfig eth1 channel 4
# set ssid
sudo iwconfig eth1 essid formhub_local
# set WEP key
sudo iwconfig eth1 key 1234567890
sudo iwconfig eth1 commit > /dev/null 2>&1

if [ $? -ne 0 ]
then
    # adhoc network setup failed
    echo The server is now running at http://localhost
    echo
    echo Adhoc network could not be created.
    echo Please connect to a router and use your assigned IP address
    echo to access the server.
else
    # bring interface back up
    sudo ip link set eth1 up
    # set an IP address
    sudo ip addr add 192.168.1.1/16 dev eth1
    # start dhcpd
    sudo /etc/init.d/dhcp3-server start

    # network created, add startup directive 
    echo 'sudo -u formhub /home/formhub/bin/adhoc.sh' | sudo tee /etc/init.d/adhoc > /dev/null
    sudo update-rc.d adhoc defaults
    echo The server is now running at http://192.168.1.1
    echo
    echo Adhoc network created.
    echo Network SSID: formhub_local
    echo Network WEP Key: 1234567890
fi

