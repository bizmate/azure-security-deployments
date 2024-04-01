
resource "azurerm_linux_virtual_machine" "XYZ_Internal_Secure_vm" {
  name                = "InternalSecureVm"
  computer_name = "InternalSecureVm"
  resource_group_name = azurerm_resource_group.XYZ_rg.name
  location            = azurerm_resource_group.XYZ_rg.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.XYZ_Internal_Secure_vm_netint.id,
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
resource "azurerm_network_interface" "XYZ_Internal_Secure_vm_netint" {
  name                = "XYZ_Internal_Secure_vm_netint"
  location            = azurerm_resource_group.XYZ_rg.location
  resource_group_name = azurerm_resource_group.XYZ_rg.name

  ip_configuration {
    name                          = "internal"
    #subnet_id                     = azurerm_subnet.XYZ_Internal_Secure_subnet.id
    subnet_id                     = azurerm_virtual_network.XYZ_Internal_vnet.subnet.*.id[2]
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "XYZ_Internal_Secure_nsg" {
  name                = "XYZ_Internal_Secure_nsg"
  location            = azurerm_resource_group.XYZ_rg.location
  resource_group_name = azurerm_resource_group.XYZ_rg.name
}
