terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.37.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "crgar-fd-appsvc-glb-terraform-rg"
    storage_account_name = "crgarfdappsvctfstor"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}
provider "azurerm" {
  features {}
}

# Configuration for the "secondary" subscription
provider "azurerm" {
  alias           = "domain-subscription"
  tenant_id       = var.dns_subscription_tenant_id
  subscription_id = var.dns_subscription_id
  client_id       = var.dns_subscription_client_id
  client_secret   = var.dns_subscription_client_secret
  features {}
}

# #################################
# #           Hub-EUS
# #################################
# module "hub-eus" {
#   source          = "./modules/hub"
#   prefix          = "${var.prefix}-eus-hub"
#   location        = "eastus"
#   ip_second_octet = "222"
#   ssh_username    = var.SSH_USERNAME
#   ssh_password    = var.SSH_PASSWORD
# }

# #################################
# #           Spoke-EUS
# #################################
# module "spoke_eus_s1" {
#   source          = "./modules/spoke"
#   prefix          = "${var.prefix}-eus-s1"
#   location        = "eastus"
#   ip_second_octet = "223"
#   hub_vnet_name   = module.hub-eus.hub_vnet_name
#   hub_vnet_id     = module.hub-eus.hub_vnet_id
#   hub_rg_name     = module.hub-eus.hub_rg_name
#   fw_vip          = module.hub-eus.fw_vip
#   ssh_username    = var.SSH_USERNAME
#   ssh_password    = var.SSH_PASSWORD

#   depends_on = [
#     module.hub-eus
#   ]
# }


# ##DELETE ALL
# #################################
# #           Hub-WEU
# #################################
# module "hub_weu" {
#   source          = "./modules/hub"
#   prefix          = "${var.prefix}-weu-hub"
#   location        = "westeurope"
#   ip_second_octet = "111"
#   ssh_username    = var.SSH_USERNAME
#   ssh_password    = var.SSH_PASSWORD
# }

# #################################
# #           Spokes-WEU
# #################################
# module "spoke_weu_s1" {
#   cost_reduction          = var.cost_reduction
#   source                  = "./modules/spoke"
#   prefix                  = "${var.prefix}-weu-s1"
#   location                = "westeurope"
#   ip_second_octet         = "113"
#   hub_vnet_name           = module.hub_weu.hub_vnet_name
#   hub_vnet_id             = module.hub_weu.hub_vnet_id
#   hub_rg_name             = module.hub_weu.hub_rg_name
#   fw_vip                  = module.hub_weu.fw_vip
#   ssh_username            = var.SSH_USERNAME
#   ssh_password            = var.SSH_PASSWORD

#   depends_on = [
#     module.hub_weu
#   ]
# }

# resource "azurerm_resource_group" "frontdoor_rg" {
#   name     = "${var.prefix}-front_door_rg"
#   location = "westeurope"
# }

# # module "frontfoor" {
# #   prefix              = "${var.prefix}-frontdoor"
# #   source              = "./modules/frontdoor"
# #   resource_group_name = azurerm_resource_group.frontdoor_rg.name

# #   providers = {
# #     azurerm.domain-subscription = azurerm.domain-subscription
# #   }
# # }

# #################################
# #           Hub Peerings
# #################################

# # resource "azurerm_virtual_network_peering" "hub-hubweu" {
# #   name                      = "hub-hubweu"
# #   resource_group_name       = module.hub-eus.hub_rg_name
# #   virtual_network_name      = module.hub-eus.hub_vnet_name
# #   remote_virtual_network_id = module.hub_weu.hub_vnet_id
# # }

# # resource "azurerm_virtual_network_peering" "hubweu-hub" {
# #   name                      = "hubweu-hub"
# #   resource_group_name       = module.hub_weu.hub_rg_name
# #   virtual_network_name      = module.hub_weu.hub_vnet_name
# #   remote_virtual_network_id = module.hub-eus.hub_vnet_id
# # }
