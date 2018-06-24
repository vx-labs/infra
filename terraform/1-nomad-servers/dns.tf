resource "cloudflare_record" "cluster_masters" {
  count  = "${var.master_count}"
  domain = "${var.cloudflare_domain}"
  name   = "servers.nomad.discovery.${var.region}"
  value  = "${element(scaleway_server.nomad-server.*.private_ip, count.index)}"
  type   = "A"
  ttl    = 1
}
resource "cloudflare_record" "nomad_servers" {
  count  = "${var.master_count}"
  domain = "${var.cloudflare_domain}"
  name   = "servers.nomad.${var.region}"
  value  = "${element(scaleway_server.nomad-server.*.public_ip, count.index)}"
  type   = "A"
  ttl    = 1
}
