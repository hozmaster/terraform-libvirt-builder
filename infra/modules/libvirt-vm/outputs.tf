output "k3s_nodes_ips" {
  description = "A map of lists containing K3s node IP addresses"
  value = {
    masters = var.master_ips
    # workers = var.worker_ips
  }
}

