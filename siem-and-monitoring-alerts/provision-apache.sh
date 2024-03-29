#!/usr/bin/env bash
set -e

#apache setup
sudo apt update -y
sudo apt install -y apache2
sudo service apache2 start
#filebeat setup
curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.4.0-amd64.deb
sudo dpkg -i filebeat-7.4.0-amd64.deb
cd /etc/filebeat
sudo mv filebeat.yml filebeat.yml_backup 2>/dev/null
#edit filebeat.yml and change the value for output.elasticsearch and setup.kibana to reflect the IP of your Elk server
sudo curl -L -o filebeat.yml https://raw.githubusercontent.com/bizmate/azure-security-deployments/main/siem-and-monitoring-alerts/filebeat-template.yml
echo "Adding ELK IP's to filebeat config"
sudo sed -i 's/SIEM_ELASTICSEARCH_HOST/'"$SIEM_ELK_PRIVATE_IP"'/g' filebeat.yml
sudo filebeat modules enable system
sudo filebeat modules enable apache
sudo filebeat setup
sudo service filebeat start
# check if filebeat can connect by testing the output
sudo filebeat test output
