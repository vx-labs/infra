variable "logzio_token" {}
variable "datadog_token" {}
variable "cloudflare_email" {}
variable "cloudflare_token" {}
variable "cloudflare_domain" {}

provider "cloudflare" {
  version = "~> 2.0"
  email   = var.cloudflare_email
  api_key = var.cloudflare_token
}

variable "region" {
  default = "fr-par"
}

variable "zone" {
  default = "fr-par-1"
}

provider "scaleway" {
  version      = "~> 1.11"
  region       = var.region
  zone         = var.zone
}
