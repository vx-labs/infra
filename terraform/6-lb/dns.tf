resource "cloudflare_record" "entrypoint" {
  domain = "${var.cloudflare_domain}"
  name   = "cloud"
  value  = "${scaleway_ip.nomad-lb-ip.ip}"
  type   = "A"
  ttl    = 1
}
