# Copyright (c) 2026.  Olli-Pekka Wallin All rights reserved

variable "vm_name" {
  type        = string
  description = "name of the vm"
}

variable "vm_cpu_count" {
  type        = string
  description = "The CPU count of the VM(s)"
}

variable "vm_memory_size_mb" {
  type        = number
  description = "The memory size of the VM(s) in MB"
}

variable "source_disk_image" {
  type        = string
  description = "The name of the source disk image in the pool"
}

####
variable "data_storage_path" {
  type        = string
  default     = "/opt/libvirt/legnano"
  description = "Base folder for data-storage (pool)"
}

variable "libvirt_path" {
  type        = string
  description = "The base path of the where storages and images are located"
}

variable "data_disk" {
  type        = string
  default     = "legnano-data-disk.qcow2"
  description = "The name of the target disk mage in the pool"
}

variable "data_disk_size_gb2" {
  type        = number
  default     = 20
  description = "The multiplier for data data disk size"
}

variable "hostname" {
  type        = string
  default     = "legnano"
  description = "The hostname of the vm"
}

variable "ssh_public_key_path" {
  description = "Path to your SSH public key"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "master_ips" {
  type    = list(string)
  default = ["192.168.2.140"]
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
