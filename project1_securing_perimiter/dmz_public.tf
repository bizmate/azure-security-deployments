
resource "azurerm_subnet" "XYZ_DMZ_Public_subnet" {
  name                 = "XYZ_DMZ_Public_subnet"
  resource_group_name  = azurerm_resource_group.XYZ_rg.name
  virtual_network_name = azurerm_virtual_network.XYZ_DMZ_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_linux_virtual_machine" "XYZ_DMZ_Public_vm" {
  name                = "DmzPublicVm"
  computer_name = "DmzPublicVm"
  resource_group_name = azurerm_resource_group.XYZ_rg.name
  location            = azurerm_resource_group.XYZ_rg.location
  size                = "Standard_B1s"
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
    name                          = "internal_and_public"
    subnet_id                     = azurerm_subnet.XYZ_DMZ_Public_subnet.id
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