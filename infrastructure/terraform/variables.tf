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

variable "ssh_open_to_internet" {
  type    = bool
  default = false
}

variable "enable_password_login" {
  type    = bool
  default = false
}

variable "admin_password" {
  type      = string
  default   = null
  sensitive = true
}

variable "allow_updates_outbound" {
  type    = bool
  default = false
}