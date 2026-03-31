base_image_path = "/kvm-storage/ubuntu-base.qcow2"

vms = {
  master = {
    ip     = "192.168.122.50/24"
    memory = 2048
    vcpu   = 2
    disk   = 20 * 1024 * 1024 * 1024
  }

  worker1 = {
    ip     = "192.168.122.51/24"
    memory = 2048
    vcpu   = 2
    disk   = 20 * 1024 * 1024 * 1024
  }

  worker2 = {
    ip     = "192.168.122.52/24"
    memory = 2048
    vcpu   = 2
    disk   = 20 * 1024 * 1024 * 1024
  }
}

