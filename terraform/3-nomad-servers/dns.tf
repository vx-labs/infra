resource "cloudflare_record" "masters_discovery" {
  count = "${length(var.master_images)}"
  domain = "${var.cloudflare_domain}"
  name   = "servers.nomad.discovery.${var.region}"
  value  = "${element(scaleway_server.nomad-masters.*.private_ip, count.index)}"
  type   = "A"
  ttl    = 1
}
resource "cloudflare_record" "nomad_servers_1" {
  count = "${length(var.master_images)}"
  domain = "${var.cloudflare_domain}"
  name   = "servers.nomad.${var.region}"
  value  = "${element(scaleway_server.nomad-masters.*.public_ip, count.index)}"
  type   = "A"
  ttl    = 1
}
