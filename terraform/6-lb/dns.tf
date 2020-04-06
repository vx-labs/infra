data "cloudflare_zones" "main_zone" {
  filter {
    name   = var.cloudflare_domain
    status = "active"
    paused = false
  }
}
resource "cloudflare_record" "entrypoint" {
  zone_id = data.cloudflare_zones.main_zone.zones[0].id
  name   = "cloud"
  value  = scaleway_instance_ip.lb_ip.address
  type   = "A"
  ttl    = 1
}
resource "cloudflare_record" "admin" {
  zone_id = data.cloudflare_zones.main_zone.zones[0].id
  name   = "lb.${var.region}"
  value  = scaleway_instance_ip.lb_ip.address
  type   = "A"
  ttl    = 1
}
resource "cloudflare_record" "services" {
  zone_id = data.cloudflare_zones.main_zone.zones[0].id
  name   = "*.services.discovery.${var.region}"
  value  = module.lb-1.instance_private_ip
  type   = "A"
  ttl    = 1
}
