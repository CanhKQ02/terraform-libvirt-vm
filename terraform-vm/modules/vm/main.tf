terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

# =========================
# CLOUD INIT
# =========================
resource "libvirt_cloudinit_disk" "init" {
  name = "${var.name}-cloudinit.iso"
  pool = var.pool_name

  user_data = templatefile("${path.module}/cloud_init/common.yml", {
    hostname = var.name
    ssh_key  = var.ssh_key
  })

  network_config = templatefile("${path.module}/cloud_init/network.yml", {
    interface_name = var.network_interface_name
    ip_cidr        = var.ip_cidr
    gateway        = var.network_gateway
    dns_csv        = join(", ", var.network_dns)
  })
}

# =========================
# DISK (CLONE FROM BASE IMAGE)
# =========================
resource "libvirt_volume" "disk" {
  name           = "${var.name}.qcow2"
  pool           = var.pool_name
  base_volume_id = var.base_volume
  size           = var.disk_size
}

# =========================
# VM
# =========================
resource "libvirt_domain" "vm" {
  name       = var.name
  memory     = var.memory
  vcpu       = var.vcpu
  qemu_agent = true

  cpu {
    mode = "host-passthrough"
  }

  network_interface {
    network_name   = var.network_name
    wait_for_lease = false
  }

  disk {
    volume_id = libvirt_volume.disk.id
  }

  cloudinit = libvirt_cloudinit_disk.init.id

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }
}

