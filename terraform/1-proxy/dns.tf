resource "cloudflare_record" "proxies-discovery" {
  count = "${length(var.proxy_images)}"
  domain = "${var.cloudflare_domain}"
  name   = "http.proxy.discovery.${var.region}"
  value  = "${element(scaleway_server.proxies.*.private_ip, count.index)}"
  type   = "A"
  ttl    = 1
}
resource "cloudflare_record" "proxies" {
  count = "${length(var.proxy_images)}"
  domain = "${var.cloudflare_domain}"
  name   = "http.proxy.${var.region}"
  value  = "${element(scaleway_server.proxies.*.public_ip, count.index)}"
  type   = "A"
  ttl    = 1
}
resource "cloudflare_record" "proxy_direct" {
  count = "${length(var.proxy_images)}"
  domain = "${var.cloudflare_domain}"
  name   = "${count.index}.http.proxy.${var.region}"
  value  = "${element(scaleway_server.proxies.*.public_ip, count.index)}"
  type   = "A"
  ttl    = 1
}
