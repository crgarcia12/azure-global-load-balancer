################################
#         Generics
################################
variable "cost_reduction" {
  description = "Set to true to reduce costs by not deploying expensive resources"
  type        = bool
}

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

variable "ssh_username" {
  type      = string
  sensitive = true
}

variable "ssh_password" {
  type      = string
  sensitive = true
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

variable "fw_vip" {
  type = string
}