data "scaleway_image" "lb" {
  architecture = "x86_64"
  name         = "${element(var.lb_images, 0)}"
}

resource "scaleway_ip" "nomad-lb-ip" {
  server = "${module.lb-1.instance_id}"
}

module "lb-1" {
  source           = "../modules/instance"
  image            = "${element(var.lb_images, 0)}"
  secgroup         = "${scaleway_security_group.nomad_lb.id}"
  hostname         = "lb-1"
  region           = "${var.region}"
  domain           = "${var.cloudflare_domain}"
  cloudinit        = "${file("config.yaml")}"
  discovery_record = "servers.lb"
  user_data_count  = 1
}

resource "scaleway_user_data" "consul_join_list" {
  server = "${module.lb-1.instance_id}"
  key    = "CONSUL_JOIN_LIST"
  value  = "servers.consul.discovery.${var.region}.${var.cloudflare_domain}"
}

resource "scaleway_security_group" "nomad_lb" {
  name        = "nomad-lb"
  description = "Nomad load-balancers"
}

resource "scaleway_security_group_rule" "ssh_accept" {
  security_group = "${scaleway_security_group.nomad_lb.id}"

  action    = "accept"
  direction = "inbound"
  ip_range  = "${var.management_ip}"
  protocol  = "TCP"
  port      = 22
}

resource "scaleway_security_group_rule" "drop_all_ssh" {
  security_group = "${scaleway_security_group.nomad_lb.id}"
  depends_on     = ["scaleway_security_group_rule.ssh_accept"]

  action    = "drop"
  direction = "inbound"
  ip_range  = "0.0.0.0/0"
  protocol  = "TCP"
  port      = 22
}
