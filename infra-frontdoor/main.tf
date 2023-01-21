terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.37.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "crgar-fd-glb-terraform-rg"
    storage_account_name = "crgarfdglbterraformstor"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
provider "azurerm" {
  features {}
}

#################################
#           Hub-EUS
#################################
module "hub-eus" {
  source          = "./modules/hub"
  prefix          = "${var.prefix}-eus-hub"
  location        = "eastus"
  ip_second_octet = "222"
  ssh_username    = var.SSH_USERNAME
  ssh_password    = var.SSH_PASSWORD
}

#################################
#           Spoke-EUS
#################################
module "spoke_eus_s1" {
  source               = "./modules/spoke"
  prefix               = "${var.prefix}-eus-s1"
  location             = "eastus"
  ip_second_octet      = "223"
  hub_vnet_name        = module.hub-eus.hub_vnet_name
  hub_vnet_id          = module.hub-eus.hub_vnet_id
  hub_rg_name          = module.hub-eus.hub_rg_name
  fw_vip               = module.hub-eus.fw_vip
  ssh_username         = var.SSH_USERNAME
  ssh_password         = var.SSH_PASSWORD

  depends_on = [
    module.hub-eus
  ]
}

#################################
#           Hub-WEU
#################################
module "hub_weu" {
  source          = "./modules/hub"
  prefix          = "${var.prefix}-weu-hub"
  location        = "westeurope"
  ip_second_octet = "111"
  ssh_username    = var.SSH_USERNAME
  ssh_password    = var.SSH_PASSWORD
}

#################################
#           Spokes-WEU
#################################
module "spoke_weu_s1" {
  source                  = "./modules/spoke"
  prefix                  = "${var.prefix}-weu-s1"
  location                = "westeurope"
  ip_second_octet         = "113"
  hub_vnet_name           = module.hub_weu.hub_vnet_name
  hub_vnet_id             = module.hub_weu.hub_vnet_id
  hub_rg_name             = module.hub_weu.hub_rg_name
  aks_network_plugin_mode = null
  aks_ebpf_data_plane     = null
  fw_vip                  = module.hub_weu.fw_vip
  ssh_username            = var.SSH_USERNAME
  ssh_password            = var.SSH_PASSWORD

  depends_on = [
    module.hub_weu
  ]
}

#################################
#           Hub Peerings
#################################

resource "azurerm_virtual_network_peering" "hub-hubweu" {
  name                      = "hub-hubweu"
  resource_group_name       = module.hub-eus.hub_rg_name
  virtual_network_name      = module.hub-eus.hub_vnet_name
  remote_virtual_network_id = module.hub_weu.hub_vnet_id
}

resource "azurerm_virtual_network_peering" "hubweu-hub" {
  name                      = "hubweu-hub"
  resource_group_name       = module.hub_weu.hub_rg_name
  virtual_network_name      = module.hub_weu.hub_vnet_name
  remote_virtual_network_id = module.hub-eus.hub_vnet_id
}
