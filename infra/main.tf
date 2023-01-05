terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.0.0"
    }
  }
}
provider "azurerm" {
  features {}
}

variable "location" {
  type    = string
}

variable "prefix" {
  type    = string
}

resource "azurerm_resource_group" "weu_rg" {
  name     = "${var.prefix}-weu-rg"
  location = var.location
}

resource "azurerm_resource_group" "hub_rg" {
  name     = "${var.prefix}-hub-rg"
  location = var.location
}

module "hub_vnet" {
  source  = "./modules/hub/vnet"
  prefix = "${var.prefix}-hub"
  location = var.location
  ip_second_octet = "200"
  resourcegroup_name = azurerm_resource_group.hub_rg.name
}

module "weu_vnet" {
  source  = "./modules/spoke/vnet"
  prefix = "${var.prefix}-weu"
  location = var.location
  ip_second_octet = "210"
  resourcegroup_name = azurerm_resource_group.weu_rg.name
  hub_vnet_rg_name = azurerm_resource_group.hub_rg.name
  hub_vnet_id = module.hub_vnet.vnet_id
  hub_vnet_name = module.hub_vnet.vnet_name
}