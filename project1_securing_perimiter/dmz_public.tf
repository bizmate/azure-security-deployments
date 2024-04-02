
resource "azurerm_linux_virtual_machine" "XYZ_DMZ_Public_vm" {
  name                = "DmzPublicVm"
  computer_name = "DmzPublicVm"
  resource_group_name = azurerm_resource_group.XYZ_rg.name
  location            = azurerm_resource_group.XYZ_rg.location
  size                = "Standard_DS1_v2"
  #size                = "B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.XYZ_DMZ_Public_vm_netint.id,
  ]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}
resource "azurerm_network_interface" "XYZ_DMZ_Public_vm_netint" {
  name                = "XYZ_DMZ_Public_vm_netint"
  location            = azurerm_resource_group.XYZ_rg.location
  resource_group_name = azurerm_resource_group.XYZ_rg.name

  ip_configuration {
    name                          = "XYZ_DMZ_Ip_public"
    #subnet_id                     = index(azurerm_virtual_network.XYZ_DMZ_vnet.subnet.*.name, "XYZ_DMZ_Public_subnet")
    subnet_id                     = azurerm_virtual_network.XYZ_DMZ_vnet.subnet.*.id[0]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.XYZ_DMZ_Public_vm_public_ip.id
  }
}
resource "azurerm_public_ip" "XYZ_DMZ_Public_vm_public_ip" {
  name                = "XYZ_DMZ_Public_vm_public_ip"
  resource_group_name = azurerm_resource_group.XYZ_rg.name
  location            = azurerm_resource_group.XYZ_rg.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_security_group" "XYZ_DMZ_Public_nsg" {
  name                = "XYZ_DMZ_Public_nsg"
  location            = azurerm_resource_group.XYZ_rg.location
  resource_group_name = azurerm_resource_group.XYZ_rg.name
}


resource "azurerm_network_security_rule" "XYZ_DMZ_NSR_public_AllowSSH" {
  name                        = "XYZ_DMZ_NSRAllowSSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.XYZ_rg.name
  network_security_group_name = azurerm_network_security_group.XYZ_DMZ_Public_nsg.name
}

resource "azurerm_network_security_rule" "XYZ_DMZ_NSRAllowHttp" {
  name                        = "XYZ_DMZ_NSRAllowHttp"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  //  destination_address_prefix  = azurerm_public_ip.XYZ_DMZ_Public_vm_public_ip.ip_address
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.XYZ_rg.name
  network_security_group_name = azurerm_network_security_group.XYZ_DMZ_Public_nsg.name
}


resource "azurerm_network_security_rule" "XYZ_DMZ_NSRAllowElk" {
  name                        = "AllowElk"
  priority                    = 300
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "9200"
  //  source_address_prefix       = azurerm_virtual_network.XYZ_DMZ_vnet.subnet.address_prefix
  //  destination_address_prefix  = azurerm_virtual_network.XYZ_DMZ_vnet.subnet.address_prefix
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = azurerm_linux_virtual_machine.XYZ_DMZ_Public_vm.private_ip_address
  resource_group_name         = azurerm_resource_group.XYZ_rg.name
  network_security_group_name = azurerm_network_security_group.XYZ_DMZ_Public_nsg.name
}

resource "azurerm_network_security_rule" "XYZ_DMZ_NSRAllowKibana" {
  name                        = "AllowKibana"
  priority                    = 400
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "5601"
  //  source_address_prefix       = azurerm_virtual_network.XYZ_DMZ_vnet.subnet.address_prefix
  //  destination_address_prefix  = azurerm_virtual_network.XYZ_DMZ_vnet.subnet.address_prefix
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = azurerm_linux_virtual_machine.XYZ_DMZ_Public_vm.private_ip_address
  resource_group_name         = azurerm_resource_group.XYZ_rg.name
  network_security_group_name = azurerm_network_security_group.XYZ_DMZ_Public_nsg.name
}

resource "azurerm_network_security_rule" "XYZ_DMZ_NSR_public_AllowSSHfromVPN" {
  name                        = "AllowSSHfromVPN"
  priority                    = 500
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "172.16.1.0/24"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.XYZ_rg.name
  network_security_group_name = azurerm_network_security_group.XYZ_DMZ_Public_nsg.name
}

resource "azurerm_network_security_rule" "AllowKibanaFromVPN" {
  name                        = "AllowKibanaFromVPN"
  priority                    = 600
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "5601"
  //  source_address_prefix       = azurerm_virtual_network.XYZ_DMZ_vnet.subnet.address_prefix
  //  destination_address_prefix  = azurerm_virtual_network.XYZ_DMZ_vnet.subnet.address_prefix
  source_address_prefix       = "172.16.1.0/24"
  destination_address_prefix  = azurerm_linux_virtual_machine.XYZ_DMZ_Public_vm.private_ip_address
  resource_group_name         = azurerm_resource_group.XYZ_rg.name
  network_security_group_name = azurerm_network_security_group.XYZ_DMZ_Public_nsg.name
}