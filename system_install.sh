# network connection required
ping -c 1 google.com 2>&1 | grep unknown
if [ $? -eq 0 ]
    then
        echo Network connection not found. Please connect and try again
        exit 1
fi

# install formhub system dependencies
sudo apt-get -qq install git-core
sudo apt-get -qq install python-setuptools

# install python pip installation tool
sudo easy_install pip

# clone shell scripts repo?
cd ~
git clone https://github.com/modilabs/formhub-deploy-scripts.git bin
cd bin
sudo chmod u+x .
cd ~

echo "/bin/bash ~/bin/bash_profile_extender.sh" >> ~/.bashrc
source ~/.bashrc

# create a directory for formhub
mkdir site
cd site
# clone git repo from 
git clone https://github.com/modilabs/formhub.git -b local-node

# change into site directory
cd formhub

# install site specific requirements
pip install -r requirements.pip

# handle local_settings (somehow, if we want to...)
# TODO

# syncdb & migrate
python manage.py syncdb
python manage.py migrate

# sudo privileges to run server in screen
sudo echo 'formhub ALL=(ALL) NOPASSWD: /home/formhub/bin/run_server.sh' >> /etc/sudoers

# install reverse ssh cron
echo '*/3 * * * * /bin/bash /home/formhub/bin/reverse_ssh.sh >/dev/null 2>&1' | crontab

