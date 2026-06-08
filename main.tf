
# Copyright (c) 2026.  Olli-Pekka Wallin All rights reserved
terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

provider "libvirt" {
  uri = var.provider_uri
}

module "project_legnano" {
  source = "./modules/legnano-vm"

  vm_name = "vm_${var.vm_name}"
  vm_cpu_count       = var.vm_cpu_count
  source_disk_image = var.source_disk
  vm_memory_size_mb = var.vm_memory_size_mb

  libvirt_path = var.libvirt_path
}
