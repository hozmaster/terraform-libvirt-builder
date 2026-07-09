

# Copyright (c) 2026.  Olli-Pekka Wallin All rights reserved

variable "provider_uri" {
  type        = string
  default     = "qemu:///system"
  description = "Address of the Qemu system (uri)"
}

variable "vm_name" {
  type        = string
  default     = "legnano"
  description = "The name to give to the VM(s)"
}

variable "vm_cpu_count" {
  type        = number
  default     = 2
  description = "The CPU count of the VM(s)"
}

variable "vm_memory_size_mb" {
  type        = number
  default     = 4096
  description = "The memory size of the VM(s) in MB"
}

variable "source_disk_image" {
  type        = string
  default     = "rocky-10-gc.qcow2"
  description = "The name of the source disk image in the pool"
}

variable "libvirt_path" {
  type        = string
  default     = "/opt/libvirt"
  description = "The base path of the where storages and images are located"
}

variable "hostname" {
  type    = string
  default = ""
}

variable "master_ips" {
  type    = list(string)
  default = ["192.1682.2.50"]
}

variable "ci_user" {
  type        = string
  default     = ""
  description = "The name of the root user in the vm"
}

variable "ci_password"  {
  type        = string
  default     = ""
  description = "Root user password"
}
