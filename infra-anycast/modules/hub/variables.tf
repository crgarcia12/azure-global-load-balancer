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
  description = "Region"
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

variable "vm_sku" {
  description = "VM SKU"
  type        = string
}

variable "deploy_bastion" {
  description = "Deploy Bastion"
  type        = bool
}