
# Copyright (c) 2026.  Olli-Pekka Wallin All rights reserved

module "k3s_nodes" {
  source = "../../modules/libvirt-vm"

  vm_name           = "vm_${var.vm_name}"
  vm_cpu_count      = var.vm_cpu_count
  source_disk_image = var.source_disk_image
  vm_memory_size_mb = var.vm_memory_size_mb
  hostname          = var.hostname
  libvirt_path      = var.libvirt_path
  master_ips        = var.master_ips

  ci_user     = var.ci_user
  ci_password = var.ci_password

  # net
  # dns_servers  = ["1.1.1.1", "8.8.8.8"]

}

locals {
  master_ips = join(",", var.master_ips)
}

# Dynamic inventory
# data "template_file" "inventory" {
#   # template = file("${path.module}/../../,,/ansible/inventory/hosts.ini.tmpl")
#   template = file("${path.module}/../../../ansible/inventory/hosts.ini.tmpl")
#   vars = {
#     k3s_ips = local.master_ips
#   }
# }

# resource "local_file" "inventory" {
#   filename = "${path.module}/../../ansible/inventory/hosts.ini"
#   content  = data.template_file.inventory.rendered
# }

# k3s token
resource "random_password" "k3s_token" {
  length  = 32
  special = false
}

resource "local_file" "k3s_vars" {
  filename = "${path.module}/../../../ansible/playbooks/k3s-vars.yml"
  content = yamlencode({
    k3s_state                = "installed"
    k3s_token                = random_password.k3s_token.result
    k3s_registration_address = module.k3s_nodes.ip
  })
}

// value = libvirt_domain.example.network_interface[0].addresses[0]

# # Run Ansible
# resource "null_resource" "provision_k3s" {
#   depends_on = [
#     module.k3s_nodes,
#     local_file.inventory,
#     local_file.k3s_vars
#   ]
#
#   provisioner "local-exec" {
#     working_dir = "${path.module}/../../ansible"
#     command     = <<EOT
# ANSIBLE_HOST_KEY_CHECKING=False \
# ansible-playbook \
#   -i inventory/hosts.ini \
#   playbooks/k3s.yml
# EOT
#   }
# }

resource "null_resource" "ansible_provisioner" {
  triggers = {
    master_ips = local.master_ips
  }

  provisioner "local-exec" {
    working_dir = "${path.module}/../../../ansible"
    command = <<EOT
      if command -v ansible-playbook >/dev/null 2>&1; then
        ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
          -u matsukan \
          -i "${local.master_ips}," \
          --private-key ~/.ssh/id_ed25519 \
          playbooks/k3s.yaml
      else
        echo "ansible-playbook is not installed or not in PATH" >&2
        exit 127
      fi
    EOT
  }
}
