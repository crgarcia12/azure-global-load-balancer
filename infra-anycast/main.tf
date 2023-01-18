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
#           Hub-EUS
#################################
module "hub" {
  source          = "./modules/hub"
  prefix          = "${var.prefix}-hub"
  location        = "eastus"
  ip_second_octet = "200"
}

#################################
#           Spoke-EUS
#################################
module "spoke_weu" {
  source          = "./modules/spoke"
  prefix          = "${var.prefix}-weu"
  location        = "eastus"
  ip_second_octet = "210"
  hub_vnet_name   = module.hub.hub_vnet_name
  hub_vnet_id     = module.hub.hub_vnet_id
  hub_rg_name     = module.hub.hub_rg_name
  fw_vip          = module.hub.fw_vip

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
  fw_vip          = module.hub.fw_vip

  depends_on = [
    module.hub
  ]
}


#################################
#           Hub2
#################################
module "hub_weu" {
  source          = "./modules/hub"
  prefix          = "${var.prefix}-weu-hub"
  location        = "westeurope"
  ip_second_octet = "100"

}

#################################
#           Spoke2
#################################
module "spoke_weu_s1" {
  source                  = "./modules/spoke"
  prefix                  = "${var.prefix}-weu-s1"
  location                = "westeurope"
  ip_second_octet         = "110"
  hub_vnet_name           = module.hub_weu.hub_vnet_name
  hub_vnet_id             = module.hub_weu.hub_vnet_id
  hub_rg_name             = module.hub_weu.hub_rg_name
  aks_network_plugin_mode = null
  aks_ebpf_data_plane     = null
  fw_vip                  = module.hub_weu.fw_vip

  depends_on = [
    module.hub_weu
  ]
}

module "spoke_weu_s2" {
  source                  = "./modules/spoke"
  prefix                  = "${var.prefix}-weu-s2"
  location                = "westeurope"
  ip_second_octet         = "120"
  hub_vnet_name           = module.hub_weu.hub_vnet_name
  hub_vnet_id             = module.hub_weu.hub_vnet_id
  hub_rg_name             = module.hub_weu.hub_rg_name
  aks_network_plugin_mode = null
  aks_ebpf_data_plane     = null
  fw_vip                  = module.hub_weu.fw_vip

  depends_on = [
    module.hub_weu
  ]
}


#################################
#           Hub Peerings
#################################

resource "azurerm_virtual_network_peering" "hub-hubweu" {
  name                      = "hub-hubweu"
  resource_group_name       = module.hub.hub_rg_name
  virtual_network_name      = module.hub.hub_vnet_name
  remote_virtual_network_id = module.hub_weu.hub_vnet_id
}

resource "azurerm_virtual_network_peering" "hubweu-hub" {
  name                      = "hubweu-hub"
  resource_group_name       = module.hub_weu.hub_rg_name
  virtual_network_name      = module.hub_weu.hub_vnet_name
  remote_virtual_network_id = module.hub.hub_vnet_id
}
