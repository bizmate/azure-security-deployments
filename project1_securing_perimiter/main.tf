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
  name     = "entp-project-256371"
  location = "East US"
  tags     = {
    "DeploymentId" = "256371"
    "LaunchId"     = "1305"
    "LaunchType"   = "ON_DEMAND_LAB"
    "TemplateId"   = "1064"
    "TenantId"     = "none"
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
}

resource "azurerm_virtual_network" "XYZ_Internal_vnet" {
  name                = "XYZ_Internal_vnet"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.XYZ_rg.location
  resource_group_name = azurerm_resource_group.XYZ_rg.name
}
