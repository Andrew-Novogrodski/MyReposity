#!/usr/bin/env bash
echo updating OS
sudo apt-get update

echo upgrading OS
sudo apt-get upgrade -y

echo looking and deleting old version of Docker files
sudo apt-get remove docker docker-engine docker.io containerd runc

echo Update the apt package index and install packages to allow apt to use a repository over HTTPS
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
if [ $? != 0 ]; then exit 1; fi

echo Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"

echo Install Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
if [ $? != 0 ]; then exit 1; fi

echo Adding user to group Docker and restarting machine
sudo usermod -aG docker ubuntu
sudo shutdown -r now
