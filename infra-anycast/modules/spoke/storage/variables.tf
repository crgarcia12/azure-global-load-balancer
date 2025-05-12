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

variable "privatelink_storageblob_dns_zone_name" {
  description = "DNS Zone Name"
  type        = string
}

variable "storage_dns_zone_rg" {
  description = "Dns Zone Rg"
  type        = string
}

variable "subnet_id" {
  description = "Subnet Id"
  type        = string
}