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
resource "cloudflare_record" "cluster_lb" {
  count  = "${var.lb_count}"
  domain = "${var.cloudflare_domain}"
  name   = "entrypoint.${var.region}"
  value  = "${element(scaleway_server.nomad-lb.*.private_ip, count.index)}"
  type   = "A"
  ttl    = 1
}

resource "cloudflare_record" "nomad_servers" {
  count  = "${var.master_count}"
  domain = "${var.cloudflare_domain}"
  name   = "servers.nomad.${var.region}"
  value  = "${element(scaleway_server.nomad.*.public_ip, count.index)}"
  type   = "A"
  ttl    = 1
}

resource "cloudflare_record" "nomad_agent" {
  count  = "${var.agent_count}"
  domain = "${var.cloudflare_domain}"
  name   = "agent.nomad.${var.region}"
  value  = "${element(scaleway_server.nomad-agent.*.public_ip, count.index)}"
  type   = "A"
  ttl    = 1
}
