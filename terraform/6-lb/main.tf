data "scaleway_image" "lb" {
  architecture = "x86_64"
  name         = element(var.lb_images, 0)
}

resource "scaleway_instance_ip" "lb_ip" {}

resource "scaleway_instance_placement_group" "availability_group" {
  name        = "load-balancers"
  policy_mode = "enforced"
}

module "lb-1" {
  source             = "../modules/vault_identity-v2"
  cloud_init         = file("config.yaml")
  discovery_record   = "lb.nomad"
  image              = element(var.lb_images, 0)
  secgroup           = scaleway_security_group.nomad_lb.id
  hostname           = "lb-1"
  ip_id              = scaleway_instance_ip.lb_ip.id
  region             = var.region
  domain             = var.cloudflare_domain
  placement_group_id = scaleway_instance_placement_group.availability_group.id
  user_data = [{
    key   = "CONSUL_JOIN_LIST"
    value = "servers.consul.discovery.${var.region}.${var.cloudflare_domain}"
    }, {
    key   = "LE_EMAIL"
    value = var.letsencrypt_email
    }, {
    key   = "LB_DASHBOARD_DOMAIN"
    value = "lb.${var.region}.${var.cloudflare_domain}"
  }]
}

resource "scaleway_security_group" "nomad_lb" {
  name        = "nomad-lb"
  description = "Nomad load-balancers"
}

resource "scaleway_security_group_rule" "ssh_accept" {
  security_group = scaleway_security_group.nomad_lb.id

  action    = "accept"
  direction = "inbound"
  ip_range  = var.management_ip
  protocol  = "TCP"
  port      = 22
}

resource "scaleway_security_group_rule" "drop_all_ssh" {
  security_group = scaleway_security_group.nomad_lb.id
  depends_on     = [scaleway_security_group_rule.ssh_accept]
  action         = "drop"
  direction      = "inbound"
  ip_range       = "0.0.0.0/0"
  protocol       = "TCP"
  port           = 22
}
