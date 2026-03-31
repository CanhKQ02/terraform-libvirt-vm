variable "name" {
  type = string
}

variable "ip_cidr" {
  type = string
}

variable "memory" {
  type = number
}

variable "vcpu" {
  type = number
}

variable "disk_size" {
  type = number
}

variable "ssh_key" {
  type = string
}

variable "pool_name" {
  type = string
}

variable "base_volume" {
  type = string
}

variable "network_name" {
  type = string
}

variable "network_gateway" {
  type = string
}

variable "network_dns" {
  type = list(string)
}

variable "network_interface_name" {
  type = string
}

