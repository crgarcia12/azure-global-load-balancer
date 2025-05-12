variable "prefix" {
  type    = string
  default = "crgar-appsvc"
}
variable "SSH_USERNAME" {
  type      = string
  sensitive = true
}
variable "SSH_PASSWORD" {
  type      = string
  sensitive = true
}

variable "cost_reduction" {
  type = bool
  default = false
}

variable "dns_subscription_tenant_id" {
  type = string
  default = "b0c1d3a2-4f8e-4f5b-9a6d-7c0e2f1b5c3d"
}

variable "dns_subscription_id" {
  type = string
  default = "930c11b0-5e6d-458f-b9e3-f3dda0734110"
}

variable "dns_subscription_client_id" {
  type = string
  default = "3fe20d6f-6998-4a31-80a3-69494452ab64"
}

variable "client_secret" {
  type      = string
  sensitive = true
}

variable "dns_subscription_client_secret" {
  type      = string
  sensitive = true
}