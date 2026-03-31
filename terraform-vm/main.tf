terraform {
  required_version = ">= 1.5"

  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.8.3"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

# =========================
# SSH KEY
# =========================
data "local_file" "ssh_key" {
  filename = pathexpand(var.ssh_key_path)
}

# =========================
# VM MODULE
# =========================
module "vm" {
  source = "./modules/vm"

  for_each = var.vms

  name      = each.key
  ip_cidr   = each.value.ip
  memory    = each.value.memory
  vcpu      = each.value.vcpu
  disk_size = each.value.disk

  ssh_key = trimspace(data.local_file.ssh_key.content)

  pool_name   = var.pool_name
  base_volume = var.base_image_path   

  network_name           = var.network_name
  network_gateway        = var.network_gateway
  network_dns            = var.network_dns
  network_interface_name = var.network_interface_name
}

