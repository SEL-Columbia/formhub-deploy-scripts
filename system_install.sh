# network connection required
ping -c 1 google.com 2>&1 | grep unknown > /dev/null
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

# create sym links
sudo ln -s /home/formhub/bin/start_server.sh ~/Desktop/start-server
sudo ln -s /home/formhub/bin/stop_server.sh ~/Desktop/stop-server
sudo ln -s /home/formhub/bin/start_adhoc.sh ~/Desktop/start-adhoc-network
sudo ln -s /home/formhub/bin/stop_adhoc.sh ~/Desktop/stop-adhoc-network

# start server now
sudo /etc/init.d/formhub start

# confirm install
echo
if [ -d ~/site/formhub ] && [ -f /etc/init.d/server ]
then
    echo Installation succeeded.
    echo The server is now running at http://localhost
    echo
    echo To start the wireless network run: sudo /etc/init.d/formhub adhoc-up
    echo To stop the wireless network run: sudo /etc/init.d/formhub adhoc-down
else
    echo Installation failed.
fi

