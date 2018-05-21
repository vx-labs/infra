variable "cloudflare_email" {}
variable "cloudflare_token" {}
variable "cloudflare_domain" {}

provider "cloudflare" {
  email       = "${var.cloudflare_email}"
  token       = "${var.cloudflare_token}"
}

resource "cloudflare_record" "cluster_masters" {
  count  = "${var.master_count}"
  domain = "${var.cloudflare_domain}"
  name   = "servers.nomad.discovery.${var.region}"
  value  = "${element(scaleway_server.nomad.*.private_ip, count.index)}"
  type   = "A"
  ttl    = 1
}
