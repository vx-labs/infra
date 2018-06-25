resource "cloudflare_record" "entrypoint" {
  count  = "${var.lb_count}"
  domain = "${var.cloudflare_domain}"
  name   = "cloud"
  value  = "${element(scaleway_server.nomad-lb.*.public_ip, count.index)}"
  type   = "A"
  ttl    = 1
}
