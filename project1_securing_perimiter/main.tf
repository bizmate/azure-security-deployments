terraform {
  required_version = ">= 0.12" # Specify the required Terraform version constraint
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.0, < 4.0" # Specify the required AWS provider version constraint
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.0" # Specify the required Azure provider version constraint
    }
    # Add more providers with their respective version constraints if needed
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "XYZ_rg" {
  name     = "entp-project-256780"
  location = "West Europe"
  tags =  {
    "DeploymentId": "256780",
    "LaunchId": "1305",
    "LaunchType": "ON_DEMAND_LAB",
    "TemplateId": "1064",
    "TenantId": "none"
  }
  timeouts {}
  lifecycle {
    prevent_destroy = true
  }
}

# DMZ Resources
resource "azurerm_virtual_network" "XYZ_DMZ_vnet" {
  name                = "XYZ_DMZ_vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.XYZ_rg.location
  resource_group_name = azurerm_resource_group.XYZ_rg.name

  subnet {
    name           = "XYZ_DMZ_Public_subnet"
    address_prefix = "10.0.1.0/24"
    security_group = azurerm_network_security_group.XYZ_DMZ_Public_nsg.id
  }

  subnet {
    name           = "XYZ_DMZ_Private_subnet"
    address_prefix = "10.0.2.0/24"
    security_group = azurerm_network_security_group.XYZ_DMZ_Public_nsg.id
  }
}

resource "azurerm_virtual_network" "XYZ_Internal_vnet" {
  name                = "XYZ_Internal_vnet"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.XYZ_rg.location
  resource_group_name = azurerm_resource_group.XYZ_rg.name

  subnet {
    name           = "XYZ_Internal_Enterprise_subnet"
    address_prefix = "10.1.1.0/24"
    security_group = azurerm_network_security_group.XYZ_Internal_Enterprise_nsg.id
  }

  subnet {
    name           = "XYZ_Internal_Management_subnet"
    address_prefix = "10.1.2.0/24"
    security_group = azurerm_network_security_group.XYZ_Internal_Management_nsg.id
  }

  subnet {
    name           = "XYZ_Internal_Secure_subnet"
    address_prefix = "10.1.3.0/24"
    security_group = azurerm_network_security_group.XYZ_Internal_Secure_nsg.id
  }

  subnet {
    name           = "GatewaySubnet"
    address_prefix = "10.1.0.0/24"
  }
}

// THE BELOW CAUSES CONFLICT. Subnets cannot be stand alone or both inline
//resource "azurerm_subnet" "XYZ_Internal_GatewaySubnet_subnet" {
//  name                 = "GatewaySubnet"
//  virtual_network_name = azurerm_virtual_network.XYZ_Internal_vnet.name
//  resource_group_name  = azurerm_resource_group.XYZ_rg.name
//  address_prefixes       = ["10.1.0.0/24"]
//}
//
resource "azurerm_virtual_network_gateway" "XYZ_VPN_Gateway" {
  name                = "XYZ_VPN_Gateway"
  location            = azurerm_resource_group.XYZ_rg.location
  resource_group_name = azurerm_resource_group.XYZ_rg.name

  type     = "Vpn"
  vpn_type = "RouteBased"
  sku      = "VpnGw1"

  ip_configuration {
    public_ip_address_id          = azurerm_public_ip.XYZ_VPN_public_ip.id
    private_ip_address_allocation = "Dynamic"
    #subnet_id                     = azurerm_virtual_network.XYZ_Internal_vnet.subnet[index(azurerm_virtual_network.XYZ_Internal_vnet.subnet.*.name, "GatewaySubnet")].id
    subnet_id                     = data.azurerm_subnet.gateway_subnet.id
    #subnet_id =                   azurerm_virtual_network.XYZ_Internal_vnet.subnet.*.id[3]
  }

  depends_on = [
    azurerm_public_ip.XYZ_VPN_public_ip
  ]
}

resource "azurerm_public_ip" "XYZ_VPN_public_ip" {
  name                = "XYZ_VPN_public_ip"
  resource_group_name = azurerm_resource_group.XYZ_rg.name
  location            = azurerm_resource_group.XYZ_rg.location
  #allocation_method   = "Dynamic"
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

data "azurerm_subnet" "gateway_subnet" {
  name                 = "GatewaySubnet"
  virtual_network_name = azurerm_virtual_network.XYZ_Internal_vnet.name
  resource_group_name  = azurerm_resource_group.XYZ_rg.name

  depends_on = [
    azurerm_virtual_network.XYZ_Internal_vnet
  ]
}

data "azurerm_subnet" "enterprise_subnet" {
  name                 = "XYZ_Internal_Enterprise_subnet"
  virtual_network_name = azurerm_virtual_network.XYZ_Internal_vnet.name
  resource_group_name  = azurerm_resource_group.XYZ_rg.name

  depends_on = [
    azurerm_virtual_network.XYZ_Internal_vnet
  ]
}

data "azurerm_subnet" "management_subnet" {
  name                 = "XYZ_Internal_Management_subnet"
  virtual_network_name = azurerm_virtual_network.XYZ_Internal_vnet.name
  resource_group_name  = azurerm_resource_group.XYZ_rg.name

  depends_on = [
    azurerm_virtual_network.XYZ_Internal_vnet
  ]
}

data "azurerm_subnet" "secure_subnet" {
  name                 = "XYZ_Internal_Secure_subnet"
  virtual_network_name = azurerm_virtual_network.XYZ_Internal_vnet.name
  resource_group_name  = azurerm_resource_group.XYZ_rg.name

  depends_on = [
    azurerm_virtual_network.XYZ_Internal_vnet
  ]
}

//
//data "azurerm_virtual_network" "XYZ_DMZ_vnet" { # Read single AWS subnet
//  subnets_list = tolist(azurerm_virtual_network.XYZ_DMZ_vnet.subnet)
//  dmz_public_subnet = index(subnets_list.*.name, "XYZ_DMZ_Public_subnet")
//  subnet_id = dmz_public_subnet.id
//
//  tags = {
//    service = "vpnDeploymentSubnetId"
//  }
//}


