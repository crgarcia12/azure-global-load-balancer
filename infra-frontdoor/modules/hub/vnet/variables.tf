################################
#         Generics
################################

variable "prefix" {
  description = "prefix"
  type        = string
}

variable "location" {
  description = "location"
  type        = string
}

variable "resource_group_name" {
  description = "resource group name"
  type        = string
}

################################
#        Module params
################################

variable "ip_second_octet" {
  description = "10.<second_octet>.0.0/16"
  type        = string
  default     = "200"
}
