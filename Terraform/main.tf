locals {
  # Starting IP for the first master
  master_ip_start = 150

  # If we have N master nodes, the first worker IP = master_ip_start + N
  worker_ip_start = local.master_ip_start + var.master_count

  # Gateway for your 192.168.178.x/24 network
  gateway = "192.168.178.1"
}

###################################################
# MASTER NODES
###################################################
resource "proxmox_vm_qemu" "k3s_master" {
  count       = var.master_count
  name        = "k3s-master-${count.index + 1}"
  target_node = var.target_node

  # Full clone
  full_clone = true
  clone_id   = var.template_id
  onboot     = true

  # Match template hardware
  bios      = "seabios"
  scsihw    = "virtio-scsi-pci"
  boot      = "c"
  bootdisk  = "scsi0"
  memory    = 2048
  sockets   = 1
  cores     = 2

  # Cloud-init user & password
  ciuser     = "noah"
  cipassword = "test..123"

  # Provide your SSH public key
  sshkeys = <<-EOKEY
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCgUJR8gDgNpqKW4ujX0onSygMB/hK33vpS/3o3lcpA8bZYPE4q83PdzeqGkuKVieN4LD9OoVYY2NUbmswO8dmhNYLarPdAuIXi+fD2w+PKjkIGdvr/7zcDNjCtEb8yOKGpOuS3aboDpLqN1nmhuQMmrKBvlLgBL+7oAOPEcQBafggoRvH00gvEG5UjH7MYqhB+1QlCPxtB7JTuRTxgt9FPxMkZtdC+/VqzSzItjn/14i5DpOgSwBCXFd9/wf1P8JsGp3AurnAEmgmnJpLtg+0xiJVJyhhWNbs2D7xLGmONkuL/XEQnlO/HBO+80p7CNMGcm407CrWjnlusd9guIouGxTlHiRYC9GLzmgSQoqKpXeT0q94G3tKENGZSV6i5N7xfk6al8OB/hVEOza2IB17JTrg9YI+veVg5CUqCJf7CDKyQJFFstloUXiw24ofGH/ykmEhqri8IOvdT5UaRSazHhmji5j3VGVlIcmF4DV4UlKHUPHK8tHj/89qivgw2cyK75vxz1e59RglmCAxPLrBuZB++69G8OsCSWgjYy6rpMKfF8rTBcoAesZVVkuwn7SHIYFTpZCCzwB8KNr0R4V/50Z4pFdN2lWxs+5fzjueqy1R6aQZO9+Le7ZvVFeZTq+goWymLiKs9rDSgPQRYBqO8fKP/ZdWttS8jgcAue8z6iw== root@px
EOKEY

  # Set a static IP, e.g. 192.168.178.150, .151, ...
  ipconfig0 = "ip=192.168.178.${local.master_ip_start + count.index}/24,gw=${local.gateway}"

  # Serial console
  vga {
    type = "serial0"
  }
  serial {
    id   = 0
    type = "socket"
  }

  # NIC on vmbr0
  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }

  # Cloud-Init disk on ide2, main disk on scsi0
  disks {
    ide {
      ide2 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          storage = "local-lvm"
          size    = "20G"
        }
      }
    }
  }
}

###################################################
# WORKER NODES
###################################################
resource "proxmox_vm_qemu" "k3s_worker" {
  count       = var.worker_count
  name        = "k3s-worker-${count.index + 1}"
  target_node = var.target_node

  full_clone = true
  clone_id   = var.template_id
  onboot     = true

  bios      = "seabios"
  scsihw    = "virtio-scsi-pci"
  boot      = "c"
  bootdisk  = "scsi0"
  memory    = 2048
  sockets   = 1
  cores     = 2

  ciuser     = "noah"
  cipassword = "test..123"
  sshkeys = <<-EOKEY
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCgUJR8gDgNpqKW4ujX0onSygMB/hK33vpS/3o3lcpA8bZYPE4q83PdzeqGkuKVieN4LD9OoVYY2NUbmswO8dmhNYLarPdAuIXi+fD2w+PKjkIGdvr/7zcDNjCtEb8yOKGpOuS3aboDpLqN1nmhuQMmrKBvlLgBL+7oAOPEcQBafggoRvH00gvEG5UjH7MYqhB+1QlCPxtB7JTuRTxgt9FPxMkZtdC+/VqzSzItjn/14i5DpOgSwBCXFd9/wf1P8JsGp3AurnAEmgmnJpLtg+0xiJVJyhhWNbs2D7xLGmONkuL/XEQnlO/HBO+80p7CNMGcm407CrWjnlusd9guIouGxTlHiRYC9GLzmgSQoqKpXeT0q94G3tKENGZSV6i5N7xfk6al8OB/hVEOza2IB17JTrg9YI+veVg5CUqCJf7CDKyQJFFstloUXiw24ofGH/ykmEhqri8IOvdT5UaRSazHhmji5j3VGVlIcmF4DV4UlKHUPHK8tHj/89qivgw2cyK75vxz1e59RglmCAxPLrBuZB++69G8OsCSWgjYy6rpMKfF8rTBcoAesZVVkuwn7SHIYFTpZCCzwB8KNr0R4V/50Z4pFdN2lWxs+5fzjueqy1R6aQZO9+Le7ZvVFeZTq+goWymLiKs9rDSgPQRYBqO8fKP/ZdWttS8jgcAue8z6iw== root@px
EOKEY

  # Worker static IP, e.g. if you have 2 masters => worker IPs start at .152
  ipconfig0 = "ip=192.168.178.${local.worker_ip_start + count.index}/24,gw=${local.gateway}"

  vga {
    type = "serial0"
  }
  serial {
    id   = 0
    type = "socket"
  }

  network {
    id     = 0
    model  = "virtio"
    bridge = "vmbr0"
  }

  disks {
    ide {
      ide2 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
    scsi {
      scsi0 {
        disk {
          storage = "local-lvm"
          size    = "20G"
        }
      }
    }
  }
}
