variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "prefix" {
  type    = string
  default = "livefire-soc"
}

variable "admin_source_ips" {
  type        = list(string)
  description = "Admin IPs allowed to SSH, in CIDR form (for example 203.0.113.5/32)"
}

variable "admin_ssh_public_key" {
  type        = string
  description = "SSH public key for the admin user"
}

variable "vm_size" {
  type    = string
  default = "Standard_D2alds_v7"
}