#
#
# # Copyright (c) 2026.  Olli-Pekka Wallin All rights reserved
#
# resource "libvirt_network" "static_network" {
#   name      = "my-static-net"
#   mode      = "nat"
#   addresses = ["192.168.100.0/24"]
#
#   dhcp {
#     enabled = false
#   }
#
#   # Static IP assignment bound to a specific MAC and hostname
#   dnsmasq_options {
#     # Optional: If you want to feed custom raw settings to dnsmasq
#   }
#
#   # Direct host mappings inside the network resource XML schema
#   # Note: The syntax below aligns with the dmacvicar/libvirt provider layout
#   dns {
#     enabled    = true
#     local_only = true
#
#     hosts {
#       ip       = "192.168.100.10"
#       hostname = "vm-primary"
#     }
#   }
# }
#
#
# # resource "libvirt_domain" "vm_instance" {
# #   name   = "vm-primary"
# #   memory = "2048"
# #   vcpu   = 2
# #
# #   network_interface {
# #     network_id     = libvirt_network.static_network.id
# #     mac            = "52:54:00:12:34:56" # Must be fixed to preserve the lease
# #     wait_for_lease = true
# #   }
# #
# #   # Balance of your OS/disk configuration...
# # }
