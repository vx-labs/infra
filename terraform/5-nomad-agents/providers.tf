variable "datadog_token" {}
variable "cloudflare_email" {}
variable "cloudflare_token" {}
variable "cloudflare_domain" {}

provider "cloudflare" {
  email = "${var.cloudflare_email}"
  token = "${var.cloudflare_token}"
}

variable "scw_api_organization" {}
variable "scw_api_token" {}

variable "region" {
  default = "par1"
}

provider "scaleway" {
  organization = "${var.scw_api_organization}"
  token        = "${var.scw_api_token}"
  region       = "${var.region}"
}

provider "ct" {
  version = "0.3.1"
}
