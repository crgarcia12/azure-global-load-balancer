variable "prefix" {
  type    = string
  default = "crgar-fd"
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
  default = "Standard_D4_v5"
}