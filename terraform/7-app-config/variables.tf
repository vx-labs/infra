variable "letsencrypt_email" {}

variable "agent_count" {
  default = 3
}

variable "lb_count" {
  default = 1
}

variable "management_ip" {
  default = "92.169.229.177"
}

variable "internal_ca_cn" {
  default = "Internal Root CA"
}

variable "internal_ca_org" {
  default = "VX-Labs"
}

variable "region" {
  default = "fr-par"
}

variable "zone" {
  default = "fr-par-1"
}
