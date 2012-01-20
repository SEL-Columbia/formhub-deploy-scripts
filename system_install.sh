# network connection required
ping -c 1 google.com 2>&1 | grep unknown
if [ $? -eq 0 ]
    then exit('Network connection not found. Please connect and try again')
fi

# install formhub system dependencies
sudo apt-get -qq install git-core
sudo apt-get -qq install python-setuptools

# install python pip installation tool
sudo easy_install pip

# clone shell scripts repo?
cd ~
mkdir bin
cd bin
git clone https://github.com/modilabs/formhub_deploy_scripts.git
#chmod whatever .
cd ~

echo "sh ~/bin/bash_profile_extender.sh" >> ~/.bashrc
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
#

# syncdb & migrate
python manage.py syncdb
python manage.py migrate

#visudo priveleges
sudo visudo

