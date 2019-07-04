variable public_key_path {
  description = "Path to the public key used to connect to instance"
}

variable zone {
  description = "Zone"
}

variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-base"
}

variable "machine_type" {
  default     = "g1-small"
  description = "Machine type for reddit app instance"
}

variable "ssh_user" {
  default     = "appuser"
  description = "SSH user name"
}

variable "private_key_path" {
  description = "Path to the private key used to run provisioners"
}

variable "db_internal_address" {
  description = "MongoDB internal IP"
  default     = "127.0.0.1"
}
