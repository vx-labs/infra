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

variable "vault_google_oidc_client" {}
variable "vault_google_oidc_secret" {}
