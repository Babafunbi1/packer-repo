variable "location" {
  default = "West US"
}
variable "resource_group" {
  default = "packer-image-rg"
}
variable "vm_count" {
  default = 2
}
variable "ssh_public_key" {
  description = "Path to your SSH public key"
  type = string
}