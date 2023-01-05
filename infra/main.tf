terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.37.0"
    }
  }
}
provider "azurerm" {
  features {}
}

variable "prefix" {
  type    = string
  default = "crgar-glb"
}

resource "azurerm_resource_group" "hub_rg" {
  name     = "${var.prefix}-hub-rg"
  location = "westeurope"
}

module "hub_vnet" {
  source  = "./modules/hub/vnet"
  prefix = "${var.prefix}-hub"
  location = "westeurope"
  ip_second_octet = "200"
  resource_group_name = azurerm_resource_group.hub_rg.name
}

#################################
#           Spoke
#################################
module "spoke_weu" {
  source = "./modules/spoke"
  prefix = "${var.prefix}-weu"
  location = "westeurope"
  ip_second_octet = "210"
  hub_vnet_name = module.hub_vnet.vnet_name
  hub_vnet_id = module.hub_vnet.vnet_id
  hub_rg_name = azurerm_resource_group.hub_rg.name
}

module "spoke_neu" {
  source = "./modules/spoke"
  prefix = "${var.prefix}-neu"
  location = "northeurope"
  ip_second_octet = "220"
  hub_vnet_name = module.hub_vnet.vnet_name
  hub_vnet_id = module.hub_vnet.vnet_id
  hub_rg_name = azurerm_resource_group.hub_rg.name
}