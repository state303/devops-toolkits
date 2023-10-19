#!/bin/sh
if [ "$(id -u)" -ne 0 ] ; then echo "Please run as root" ; exit 1 ; fi

echo 'removing previous installations...'
sudo apt-get remove -y docker docker-engine docker.io containerd runc
echo 'done'

echo 'setting up repository...'
sudo apt-get update && sudo apt-get install -y ca-certificates curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
echo 'done'

echo 'installing docker engine'
sudo apt-get update && sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
echo 'done'
