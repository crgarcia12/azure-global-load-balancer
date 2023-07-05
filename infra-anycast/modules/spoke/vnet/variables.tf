################################
#         Generics
################################

variable "prefix" {
  description = "prefix"
  type        = string
}

variable "location" {
  description = "Location"
  type        = string
}

variable "resource_group_name" {
  description = "RG Name"
  type        = string
}

################################
#         Hub Vnet
################################
variable "hub_vnet_rg_name" {
  type = string
}

variable "hub_vnet_id" {
  type = string
}

variable "hub_vnet_name" {
  type = string
}

# [COST] 
# variable "fw_vip" {
#   type = string
# }

################################
#        Module params
################################

variable "ip_second_octet" {
  description = "Region"
  type        = string
}
