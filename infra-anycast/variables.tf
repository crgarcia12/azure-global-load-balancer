variable "prefix" {
  type    = string
  default = "crgar-glb"
}
variable "vm_sku" {
  type    = string
  default = "Standard_D4_v5"
}
variable "SSH_USERNAME" {
  type      = string
  sensitive = true
}
variable "SSH_PASSWORD" {
  type      = string
  sensitive = true
}

variable "SUBSCRIPTION_ID" {
  description = "The Azure subscription ID to use for the provider"
  type        = string
}