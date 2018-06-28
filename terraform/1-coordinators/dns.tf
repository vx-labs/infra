resource "cloudflare_record" "consul-discovery" {
  count = "${length(var.coordinator_images)}"
  domain = "${var.cloudflare_domain}"
  name   = "servers.consul.discovery.${var.region}"
  value  = "${element(scaleway_server.coordinators.*.private_ip, count.index)}"
  type   = "A"
  ttl    = 1
}
resource "cloudflare_record" "vault-discovery" {
  count = "${length(var.coordinator_images)}"
  domain = "${var.cloudflare_domain}"
  name   = "servers.vault.discovery.${var.region}"
  value  = "${element(scaleway_server.coordinators.*.private_ip, count.index)}"
  type   = "A"
  ttl    = 1
}
resource "cloudflare_record" "coordinators" {
  count = "${length(var.coordinator_images)}"
  domain = "${var.cloudflare_domain}"
  name   = "servers.consul.${var.region}"
  value  = "${element(scaleway_server.coordinators.*.public_ip, count.index)}"
  type   = "A"
  ttl    = 1
}

resource "cloudflare_record" "coordinator_direct" {
  count = "${length(var.coordinator_images)}"
  domain = "${var.cloudflare_domain}"
  name   = "${count.index}.servers.consul.${var.region}"
  value  = "${element(scaleway_server.coordinators.*.public_ip, count.index)}"
  type   = "A"
  ttl    = 1
}
