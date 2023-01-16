terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.37.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "crgar-glb-terraform-rg"
    storage_account_name = "crgarglbterraformstor"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
provider "azurerm" {
  features {}
}

variable "prefix" {
  type    = string
  default = "crgar-glb"
}

#################################
#           Hub
#################################
module "hub" {
  source   = "./modules/hub"
  prefix   = "${var.prefix}-hub"
  location = "eastus"
}

#################################
#           Spoke
#################################
module "spoke_weu" {
  source          = "./modules/spoke"
  prefix          = "${var.prefix}-weu"
  location        = "eastus"
  ip_second_octet = "210"
  hub_vnet_name   = module.hub.hub_vnet_name
  hub_vnet_id     = module.hub.hub_vnet_id
  hub_rg_name     = module.hub.hub_rg_name

  depends_on = [
    module.hub
  ]
}

module "spoke_eus" {
  source          = "./modules/spoke"
  prefix          = "${var.prefix}-eus"
  location        = "eastus"
  ip_second_octet = "220"
  hub_vnet_name   = module.hub.hub_vnet_name
  hub_vnet_id     = module.hub.hub_vnet_id
  hub_rg_name     = module.hub.hub_rg_name

  depends_on = [
    module.hub
  ]
}
