output "vm_info" {
  value = {
    for name, vm in var.vms :
    name => {
      ip     = split("/", vm.ip)[0]
      memory = vm.memory
      vcpu   = vm.vcpu
      disk   = vm.disk
    }
  }
}

