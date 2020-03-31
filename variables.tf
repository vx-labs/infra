variable "scw_api_organization" {}
variable "scw_access_key" {}
variable "scw_secret_key" {}

variable "letsencrypt_email" {}
variable "agent_count" {
  default = 3
}
variable "lb_count" {
  default = 1
}
variable "management_ip" {
  default = "86.247.38.60"
}

variable "internal_ca_cn" {
  default = "Internal Root CA"
}
variable "internal_ca_org" {
  default = "VX-Labs"
}
