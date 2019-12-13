resource "cloudflare_record" "proxies-discovery" {
  domain = "${var.cloudflare_domain}"
  name   = "http.proxy.discovery.${var.region}"
  value  = "${module.proxy-1.instance_private_ip}"
  type   = "A"
  ttl    = 1
}

resource "cloudflare_record" "proxies" {
  domain = "${var.cloudflare_domain}"
  name   = "http.proxy.${var.region}"
  value  = "${module.proxy-1.instance_public_ip}"
  type   = "A"
  ttl    = 1
}

resource "cloudflare_record" "ssh" {
  domain = "${var.cloudflare_domain}"
  name   = "ssh"
  value  = "${module.proxy-1.instance_public_ip}"
  type   = "A"
  ttl    = 1
}
