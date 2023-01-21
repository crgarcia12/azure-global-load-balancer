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
#         Vnet
################################
variable "subnet_id" {
  type = string
}

################################
#         Hub
################################

variable "route_server_id" {
  type = string
}

variable "route_server_bgp_peer_asn" {
  type = string
}

################################
#         VM
################################
variable "ssh_username" {
  type      = string
  sensitive = true
}
variable "ssh_password" {
  type      = string
  sensitive = true
}