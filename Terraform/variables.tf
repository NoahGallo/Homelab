variable "pm_api_url" {
  description = "Proxmox API URL (e.g. https://192.168.178.254:8006/api2/json)"
  type        = string
}

variable "pm_user" {
  description = "Proxmox user (e.g. root@pam)"
  type        = string
}

variable "pm_password" {
  description = "Proxmox password"
  type        = string
  sensitive   = true
}

variable "pm_tls_insecure" {
  description = "Set to true to disable TLS certificate verification"
  type        = bool
  default     = true
}

variable "template_id" {
  description = "ID of the cloud-init–enabled template VM"
  type        = number
  default     = 8000
}

variable "target_node" {
  description = "The Proxmox node on which to create the VMs"
  type        = string
  default     = "px"
}

variable "master_count" {
  description = "Number of master nodes"
  type        = number
  default     = 2
}

variable "worker_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 4
}
