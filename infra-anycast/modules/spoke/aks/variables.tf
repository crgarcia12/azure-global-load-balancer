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

variable "resource_group_id" {
  description = "RG Name"
  type        = string
}

variable "subnet_id" {
  description = "subnet id"
  type        = string
}

variable "vm_sku" {
  description = "VM SKU"
  type        = string
}