
# Legnano 

## Libvirt + Terraform/opentofu Homelab

**Automated KVM/QEMU virtual machine provisioning using Terraform/Opentofu and Ansible** This project create a vm and install K3s to it via Ansible playbook 

---

## Overview

This project provides a complete setup for deploying virtual machines on an Ubuntu host using **Terraform**, **Ansible** and the **libvirt** provider. It is designed for homelab environments and focuses on reliability and ease of use.

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

Make a alias:

```
$ echo 'echo "alias tf='terraform'" >> ~/.bash_aliases' >> ~/.bashrc
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
wget https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img \
     -O ubuntu-noble-24-04.img
sudo qemu-img resize ubuntu-noble-24-04.img +20G   
```

Download suitable cloud image and resize image size to suitable as needed.

## Setup the ready-to-go environment

Copy a ssh key to module to login system:
```bash
cp ~/.ssh/id_ed25519.pub infra/modulues/libvirt-vm/keys
````

Go to dev environment directory:
```bash
cd infra/environments/dev
```

Type `$ openssl passwd -G` to create hashed password <br>
Copy example file or create a 'dev.tfvars'-file and fill correct values to it:

```
vm_name = "<vm_name>"
vm_cpu_count = 1
source_disk_image = "<disk_image_file>"
vm_memory_size_mb = 2048
libvirt_path = "/opt/libvirt"
hostname = "<hostname>"
ci_userr = "ubuntu"
ci_password "<hashed_password>"
```

Save it and type :

```
$ tf init 
```
Check plan and apply it :  

```
$ tf plan -var-file=dev.tfvars
$ tf apply -var-file=dev.tfvars -auto-approve
```

**Recommended workflow:**
1. Clone this repository
2. Copy `dev.tfvars.example` to `dev.tfvars`
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
