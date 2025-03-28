terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1-rc6"
    }
  }
}

provider "proxmox" {
  # Proxmox credentials
  pm_api_url     = var.pm_api_url
  pm_user        = var.pm_user
  pm_password    = var.pm_password
  pm_tls_insecure = var.pm_tls_insecure
}
