# azure-security-deployments
Repo to deploy using Udacity Lab

### requirements
- on mac install coreutils,  `brew install coreutils`
- bash (the default shell on mac should also work too)
- make
- docker / docker-compose

Notice this might not work on Windows as I do not work or provision on Windows machines.

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

## Dockerisation

you can run the local docker instance by running 
```shell
export UID
make up
```

## Terraforming
import resource group or other resources

```shell
az login
az account set --subscription c4f47e86-cf48-4611-8c4d-6f6124a34a60
# show the resource group information
az group show -n entp-256356
# import resource group
terraform import "azurerm_resource_group.XYZ_rg"  "/subscriptions/c4f47e86-cf48-4611-8c4d-6f6124a34a60/resourceGroups/entp-256356"
```

### Destroy them all

```shell
terraform destroy -target azurerm_linux_virtual_machine.XYZ_DMZ_Private_vm -target azurerm_linux_virtual_machine.XYZ_DMZ_Public_vm -target azurerm_linux_virtual_machine.XYZ_Internal_Enterprise_vm -target azurerm_linux_virtual_machine.XYZ_Internal_Management_vm -target azurerm_linux_virtual_machine.XYZ_Internal_Secure_vm -target azurerm_network_interface.XYZ_DMZ_Private_vm_netint -target azurerm_network_interface.XYZ_DMZ_Public_vm_netint -target azurerm_network_interface.XYZ_Internal_Enterprise_vm_netint -target azurerm_network_interface.XYZ_Internal_Management_vm_netint -target azurerm_network_interface.XYZ_Internal_Secure_vm_netint -target azurerm_network_security_group.XYZ_DMZ_Private_nsg -target azurerm_network_security_group.XYZ_DMZ_Public_nsg -target azurerm_network_security_group.XYZ_Internal_Enterprise_nsg -target azurerm_network_security_group.XYZ_Internal_Management_nsg -target azurerm_network_security_group.XYZ_Internal_Secure_nsg -target azurerm_network_security_rule.XYZ_DMZ_NSRAllowElk -target azurerm_network_security_rule.XYZ_DMZ_NSRAllowHttp -target azurerm_network_security_rule.XYZ_DMZ_NSRAllowKibana -target azurerm_network_security_rule.XYZ_DMZ_NSRAllowSSH -target azurerm_public_ip.XYZ_DMZ_Public_vm_public_ip -target azurerm_public_ip.XYZ_VPN_public_ip -target azurerm_virtual_network.XYZ_DMZ_vnet -target azurerm_virtual_network.XYZ_Internal_vnet 
```

#### Terraform notes
- https://medium.com/@jaseenathan/creating-azure-resources-with-terraform-a-step-by-step-guide-af53584db357
- https://learn.microsoft.com/en-us/azure/azure-portal/get-subscription-tenant-id
- importing group https://build5nines.com/terraform-import-existing-azure-resource-group/
- remove resource from state https://stackoverflow.com/questions/61297480/how-can-i-remove-a-resource-from-terraform-state
- opened bug on the provider https://github.com/hashicorp/terraform-provider-azurerm/issues/25483
- examples of gateway https://github.com/BBE75/Terraform/blob/098b6fad2cdff40aedc87010d43cdc251d9bb90b/Part_3/global-rg1-gateway-vpn.tf
- 

#### Generic links/notes
- run remote command https://askubuntu.com/questions/1086617/dev-fd-63-no-such-file-or-directory
- https://www.elastic.co/guide/en/beats/filebeat/current/running-on-docker.html
- https://www.elastic.co/guide/en/beats/filebeat/current/configuration-autodiscover-hints.html
- https://github.com/shazChaudhry/docker-elastic/blob/master/filebeat-docker-compose.yml
- `docker run -it --rm -v ./:/opt intel/qat-crypto-base`
- https://learn.microsoft.com/en-us/azure/vpn-gateway/point-to-site-certificates-linux-openssl