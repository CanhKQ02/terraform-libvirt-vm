variable "ssh_key_path" {
  type    = string
  default = "~/.ssh/id_ed25519.pub"
}

variable "pool_name" {
  type    = string
  default = "kvm-pool"
}

variable "base_image_path" {
  type        = string
  description = "Path to existing base image"
}

variable "network_name" {
  type    = string
  default = "default"
}

variable "network_interface_name" {
  type    = string
  default = "ens3"
}

variable "network_gateway" {
  type    = string
  default = "192.168.122.1"
}

variable "network_dns" {
  type    = list(string)
  default = ["1.1.1.1", "8.8.8.8"]
}

variable "vms" {
  description = "VM definitions"
  type = map(object({
    ip     = string
    memory = number
    vcpu   = number
    disk   = number
  }))
}

