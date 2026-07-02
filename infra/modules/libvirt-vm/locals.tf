

locals {
  ssh_public_key = file("${path.module}/keys/id_ed25519.pub")
}
