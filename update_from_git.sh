#!/bin/bash
echo Updating scripts...
cd ~/bin
git pull origin master
source ~/.bashrc
echo Updating formhub...
cd ~/site/formhub
git pull origin local-node
echo
echo All done!
sleep 2
