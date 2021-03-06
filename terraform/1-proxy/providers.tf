variable "logzio_token" {}
variable "datadog_token" {}
variable "cloudflare_email" {}
variable "cloudflare_token" {}
variable "cloudflare_domain" {}

provider "cloudflare" {
  version = "~> 1.0"
  email   = "${var.cloudflare_email}"
  token   = "${var.cloudflare_token}"
}

variable "scw_api_organization" {}
variable "scw_access_key" {}
variable "scw_secret_key" {}

variable "region" {
  default = "fr-par"
}

variable "zone" {
  default = "fr-par-1"
}

provider "scaleway" {
  version      = "~> 1.11"
  organization = "${var.scw_api_organization}"
  access_key   = "${var.scw_access_key}"
  secret_key   = "${var.scw_secret_key}"
  region       = "${var.region}"
  zone         = "${var.zone}"
}
