# Copyright (c) 2026.  Olli-Pekka Wallin All rights reserved

terraform {
  required_version = "~> 1.23.5"
  required_providers {
    libvirt = {
      source = "dmacvicar/libvirt"
    }
  }
}
