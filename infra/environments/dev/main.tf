
# Copyright (c) 2026.  Olli-Pekka Wallin All rights reserved

module "vms" {
  source = "../../modules/libvirt-vm"

  vm_name = "vm_${var.vm_name}"
  vm_cpu_count       = var.vm_cpu_count
  source_disk_image = var.source_disk_image
  vm_memory_size_mb = var.vm_memory_size_mb
  hostname = var.hostname

  libvirt_path = var.libvirt_path
}
