#!/usr/bin/env bash
set -e

sudo apt update -y
sudo apt install -y docker.io python3-pip
sudo pip3 install docker
sudo sysctl -w vm.max_map_count=262144
sudo docker pull sebp/elk:761
sudo docker run -d -p 5601:5601 -p 9200:9200 -p 5044:5044 -it --name elk sebp/elk:761

echo "Going to find the private IP to add it to filebeat config"

# https://www.linuxtrainingacademy.com/determine-public-ip-address-command-line-curl/
SIEM_ELK_PRIVATE_IP=$(/sbin/ip addr show  eth0 | grep -i "inet " | awk '{print $2}'| rev | cut -c 4- | rev)
SIEM_ELK_PUBLIC_IP=$(curl https://ifconfig.me/)
echo "ELK Private IP is $SIEM_ELK_PRIVATE_IP and Public IP is $SIEM_ELK_PUBLIC_IP"
echo "export SIEM_ELK_PRIVATE_IP=$SIEM_ELK_PRIVATE_IP"
echo "export SIEM_ELK_PUBLIC_IP=$SIEM_ELK_PUBLIC_IP"
export SIEM_ELK_PRIVATE_IP
export SIEM_ELK_PUBLIC_IP
