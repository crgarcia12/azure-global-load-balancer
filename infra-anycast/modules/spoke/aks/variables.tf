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

variable "network_plugin_mode" {
  description = "network plugin mode"
  type        = string
}

variable "ebpf_data_plane" {
  description = "ebpf_data_plane"
  type        = string
}