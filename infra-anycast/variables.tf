variable "prefix" {
  type    = string
  default = "crgar-glb"
}
variable "SSH_USERNAME" {
  type      = string
  sensitive = true
}
variable "SSH_PASSWORD" {
  type      = string
  sensitive = true
}