# azure-security-deployments
Repo to deploy using Udacity Lab

Resources:
- this repo shortlink to come and copy/paste https://bit.ly/3VqafRz

## Siem and Monitoring Alerts deployment
### Deploy ELK 

```bash
curl -sL https://raw.githubusercontent.com/bizmate/azure-security-deployments/main/siem-and-monitoring-alerts/provision-elk.sh | bash
```
Check that the ELK IP is now in your shell `env | GREP ELK`

### Deploy Apache with Filebeat pointing to ELK
```bash
curl -sL https://raw.githubusercontent.com/bizmate/azure-security-deployments/main/siem-and-monitoring-alerts/provision-apache.sh | bash
```

## SSH Public key 
Mac
```shell
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCf8BFXl+5+SCel79uL4hBgxIY8JtgmjvpP4XR7sSOMeAqYbMlguW54IpLrJC660tzGNUZMqdtoP9BYSv2QUjDOy1DHjfUiDRL95/aA5WFwpMwrFfIDGhQLyUHa/zo2rH6VCSpX/7i3Nk+FQ9MTSUAij+eD9zHQCjzQdPoVPX4WfJNWnIy4HDGKbwFL8WkGMU4zFvrezqjQpxBOFk+wkoWp2bedNT7sO9lWFJqALD0r+SQz95o6qJIIlzRgo8W+Wj9NxKnM6sfmyJXGteWdpUYgZ/6ok5NhYX9QX/DP6I6ctF55nOrSv2s75Tyh57w3V7VDCdu4kdEg+D15Qh3nnzW1
```

#### Generic links/notes
- run remote command https://askubuntu.com/questions/1086617/dev-fd-63-no-such-file-or-directory