variable "guest_name" {
  type    = string
  default = "kube-infra"
}

variable "master_ip" {
  type = string
}

variable "gateway_ip" {
  type = string
}

variable "node_ips" {
  type = list(string)
}

variable "esxi_user" {
  type = string
}

variable "esxi_password" {
  type = string
}

variable "esxi_host" {
  type = string
}

variable "username" {
  type    = string
  default = "ubuntu"
}

variable "ssh_key_pub" {
  type = string
}

variable "ssh_key_priv" {
  type = string
}

variable "master_disk_size" {
  type = number
}

variable "node_disk_size" {
  type = number
}

variable "master_boot_disk_size" {
  type = number
}

variable "node_boot_disk_size" {
  type = number
}
