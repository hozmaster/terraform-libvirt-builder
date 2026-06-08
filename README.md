
# Legnano - Libvirt + Terraform Homelab

**Automated KVM/QEMU virtual machine provisioning using Terraform**

---

## Overview

This project provides a complete setup for deploying virtual machines on an Ubuntu host using **Terraform** and the **libvirt** provider. It is designed for homelab environments and focuses on reliability and ease of use.

---

## Host Prerequisites

### Phase 1: Install Required Packages

```bash
sudo apt update
sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients \
                    virt-manager bridge-utils dnsmasq
```

Add your user to the libvirt group:

```bash
sudo usermod -aG libvirt $(whoami)
newgrp libvirt
```

### Install Terraform

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | \
sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update
sudo apt install -y terraform
```

---

### Phase 2: Disable QEMU Security Driver

The Terraform libvirt provider requires this change for reliable operation.

```bash
sudo nano /etc/libvirt/qemu.conf
```

Set the following line (uncomment or add it):

```conf
security_driver = "none"
```

Apply the changes:

```bash
sudo systemctl restart libvirtd
sudo systemctl status libvirtd
```

---

### Phase 3: Prepare Storage and Base Image

```bash
# Create directory structure
sudo mkdir -p /opt/libvirt/{source,images,pools}
sudo chown -R $USER:$USER /opt/libvirt

# Download Rocky Linux 10 Cloud Image
cd /opt/libvirt/source
wget https://dl.rockylinux.org/pub/rocky/10/images/x86_64/Rocky-10-GenericCloud-Base.latest.x86_64.qcow2 \
     -O rocky-10-gc.qcow2
```

---

## Terraform Usage

```bash
terraform init
terraform validate
terraform plan
terraform apply
```

**Recommended workflow:**
1. Clone this repository
2. Copy `terraform.tfvars.example` to `terraform.tfvars`
3. Adjust variables (VM count, resources, SSH keys, etc.)
4. Run the commands above

---

## Troubleshooting

### VM fails to boot (CPU compatibility)

```bash
virsh edit <vm_name>
```

Replace the `<cpu>` section with:

```xml
<cpu mode='host-passthrough' check='none'/>
```

**Alternative with topology:**

```xml
<cpu mode='host-passthrough' check='none'>
  <topology sockets='1' dies='1' cores='4' threads='2'/>
</cpu>
```

Then restart the VM:

```bash
virsh shutdown <vm_name> --mode acpi
virsh start <vm_name>
```

