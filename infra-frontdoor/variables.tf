variable "prefix" {
  type    = string
  default = "crgar-fd"
}
variable "SSH_USERNAME" {
  type      = string
  sensitive = true
}
variable "SSH_PASSWORD" {
  type      = string
  sensitive = true
}