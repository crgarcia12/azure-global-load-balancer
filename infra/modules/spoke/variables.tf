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

variable "ip_second_octet" {
  description = "The second octet of the IP: 10.XXX.0.0/16"
  type        = string
}

################################
#         Hub
################################
variable "hub_vnet_name" {
  type = string
}

variable "hub_vnet_id" {
  type = string
}

variable "hub_rg_name" {
  type = string
}