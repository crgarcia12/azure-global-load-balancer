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

variable "aks_network_plugin_mode" {
  description = "network plugin mode"
  type        = string
  default     = "Overlay"
}

variable "aks_ebpf_data_plane" {
  description = "ebpf_data_plane"
  type        = string
  default     = "cilium"
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