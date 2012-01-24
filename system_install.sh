# network connection required
ping -c 1 google.com 2>&1 | grep unknown
if [ $? -eq 0 ]
then
    echo Network connection not found. Please connect and try again
    exit 1
fi

# install formhub system dependencies
sudo apt-get -qq update
sudo apt-get -qq install git-core
sudo apt-get -qq install python-dev
sudo apt-get -qq install python-setuptools

# install python pip installation tool
sudo easy_install pip

# clone shell scripts repo?
cd ~
git clone https://github.com/modilabs/formhub-deploy-scripts.git bin
cd bin
sudo chmod u+x .
cd ~

# add bash profile settings
cat ~/bin/bash_profile_extender.sh >> ~/.bashrc
source ~/.bashrc

# create a directory for formhub
mkdir site
cd site

# clone git repo from 
git clone https://github.com/modilabs/formhub.git -b local-node

# change into site directory
cd formhub

# install site specific requirements
sudo pip install -r requirements.pip

# handle local_settings (somehow, if we want to...)
# TODO

# syncdb & migrate
python manage.py syncdb --noinput -v0
python manage.py migrate --noinput -v0

# sudo privileges to run server in screen
echo 'formhub ALL=(ALL) NOPASSWD: /home/formhub/bin/run_server.sh' | sudo tee -a /etc/sudoers > /dev/null

# install reverse ssh cron
echo '*/3 * * * * /bin/bash /home/formhub/bin/reverse_ssh.sh >/dev/null 2>&1' | crontab

# start server on boot
sudo cp /home/formhub/bin/formhub_initd /etc/init.d/formhub
sudo update-rc.d formhub defaults

# start server now
sudo /etc/init.d/formhub start

# start adhoc network
/bin/bash /home/formhub/bin/adhoc.sh
if [ $? -ne 0 ]
then
    # adhoc network setup failed
    echo The server is now running at http://localhost
    echo
    echo Adhoc network could not be created.
    echo Please connect to a router and use your assigned IP address
    echo to access the server.
else
    # network created, add startup directive 
    echo 'sudo -u formhub /home/formhub/bin/adhoc.sh' | sudo tee /etc/init.d/adhoc > /dev/null
    sudo update-rc.d adhoc defaults
    echo The server is now running at http://192.168.1.1
    echo
    echo Adhoc network created.
    echo Network SSID: formhub_local
    echo Network WEP Key: 1234567890
fi

# confirm install
echo
if [ -d ~/site/formhub ] && [ -f /etc/init.d/server ]
then
    echo Installation succeeded.
else
    echo Installation failed.
fi

