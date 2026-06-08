# Copyright (c) 2026.  Olli-Pekka Wallin All rights reserved

terraform {
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}

resource "libvirt_pool" "vm_datastore" {
  name = "datastorage"
  type = "dir"
  target = {
    path = "${var.data_storage_path}"
  }
}

locals {
  ssh_public_key = file(pathexpand(var.ssh_public_key_path))
}

resource "libvirt_cloudinit_disk" "cloudinit_seed" {
  name = "${var.vm_name}-cloudinit-data"

  meta_data = <<-EOF
    instance-id: ${var.vm_name}
    local-hostname: ${var.vm_name}.local
  EOF

  user_data = templatefile("${path.module}/templates/user-data.yaml", {
    ssh_public_key = trimspace(local.ssh_public_key)
    hostname       = var.hostname
  })

  network_config = <<-EOF
    network:
    version: 2
    ethernets:
      en_interfaces:
        match:
          name: "en*"
        dhcp4: yes
        dhcp6: yes
  EOF
}

resource "libvirt_volume" "cloudinit_disk" {
  name = "${var.vm_name}-cloudinit-disk"
  pool = libvirt_pool.vm_datastore.name
  create = {
    content = {
      url = libvirt_cloudinit_disk.cloudinit_seed.path
    }
  }
}

resource "libvirt_volume" "data_disk" {
  name = var.data_disk
  pool = libvirt_pool.vm_datastore.name

  capacity = var.data_disk_size_gb2
  create = {
    format : "qcow2"
    content = {
      url = "file://${var.libvirt_path}/source/${var.source_disk_image}"
    }
  }
  target = {
    permissions = {
      owner = "64055"
      group = "993"
      mode  = "660"
    }
  }
}

resource "libvirt_domain" "legnano" {
  name        = var.vm_name
  memory      = var.vm_memory_size_mb
  memory_unit = "MiB"
  vcpu        = var.vm_cpu_count
  type        = "kvm"

  depends_on = [libvirt_cloudinit_disk.cloudinit_seed]
  running    = true

  os = {
    type         = "hvm"
    type_arch    = "x86_64"
    type_machine = "pc-q35-noble"
    boot_devices = [
      { dev = "hd" },
      { dev = "cdrom" }
    ]
  }

  features = {
    acpi = true
    apic = {
      apic = true
    }
    vmport = false
  }

  devices = {
    consoles = [{
      type = "pty"
      target = {
        type = "serial"
        port = "0"
      }
    }]

    serials = [{
      target = {
        type = "isa-serial"
        port = "0"
      }
    }]

    # quirk or bug, cdrom should be first otherwise it results in terraform before/after apply inconsistencies when using more disks
    # needs more trial and error to find the root cause
    disks = concat([
      {
        device = "cdrom"
        source = {
          volume = {
            pool   = libvirt_volume.cloudinit_disk.pool
            volume = libvirt_volume.cloudinit_disk.name
          }
        }
        target = {
          dev = "sda"
          bus = "sata"
        }
      },
      {
        source = {
          volume = {
            pool   = libvirt_volume.data_disk.pool
            volume = libvirt_volume.data_disk.name
          }
        }
        driver = {
          type = "qcow2"
        }
        target = {
          dev = "vda"
          bus = "virtio"
        }
      }
    ])

    interfaces = [
      {
        model = { type = "virtio" }
        source = {
          bridge = {
            bridge = "br0"
          }
        }
      }
    ]

    graphics = [
      {
        spice = {
          auto_port = true
          listeners = [
            {
              address = {}
            }
          ]
        }
      }
    ]

    videos = [{
      model = {
        type    = "virtio"
        heads   = 1
        primary = "yes"
      }
    }]

    cpu = {
      mode = "host-passthrough"
    }
  }
}
