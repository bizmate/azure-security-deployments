
resource "azurerm_linux_virtual_machine" "XYZ_Internal_Management_vm" {
  name                = "InternalManagementVm"
  computer_name = "InternalManagementVm"
  resource_group_name = azurerm_resource_group.XYZ_rg.name
  location            = azurerm_resource_group.XYZ_rg.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.XYZ_Internal_Management_vm_netint.id,
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
resource "azurerm_network_interface" "XYZ_Internal_Management_vm_netint" {
  name                = "XYZ_Internal_Management_vm_netint"
  location            = azurerm_resource_group.XYZ_rg.location
  resource_group_name = azurerm_resource_group.XYZ_rg.name

  ip_configuration {
    name                          = "internal"
    #subnet_id                     = azurerm_subnet.XYZ_Internal_Management_subnet.id
    subnet_id                     = azurerm_virtual_network.XYZ_Internal_vnet.subnet.*.id[1]
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "XYZ_Internal_Management_nsg" {
  name                = "XYZ_Internal_Management_nsg"
  location            = azurerm_resource_group.XYZ_rg.location
  resource_group_name = azurerm_resource_group.XYZ_rg.name
}

resource "azurerm_network_security_rule" "XYZ_Internal_Management_AllowSSH" {
  name                        = "AllowSSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.XYZ_rg.name
  network_security_group_name = azurerm_network_security_group.XYZ_Internal_Management_nsg.name
}


resource "azurerm_network_security_rule" "XYZ_Internal_Management_AllowSSHfromVPN" {
  name                        = "AllowSSHfromVPN"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "172.16.1.0/24"
  destination_address_prefix  = "VirtualNetwork"
  resource_group_name         = azurerm_resource_group.XYZ_rg.name
  network_security_group_name = azurerm_network_security_group.XYZ_Internal_Management_nsg.name
}
