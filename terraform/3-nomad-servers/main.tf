provider "vault" {}
module "server-1" {
  source = "./modules/nomad-master"
  image = "${element(var.master_images, 0)}"
  secgroup = "${scaleway_security_group.nomad_server.id}"
  index = "1"
  expect_count = "${length(var.master_images)}"
  region = "${var.region}"
  domain = "${var.cloudflare_domain}"
}
module "server-2" {
  source = "./modules/nomad-master"
  image = "${element(var.master_images, 1)}"
  secgroup = "${scaleway_security_group.nomad_server.id}"
  index = "2"
  expect_count = "${length(var.master_images)}"
  region = "${var.region}"
  domain = "${var.cloudflare_domain}"
}
module "server-3" {
  source = "./modules/nomad-master"
  image = "${element(var.master_images, 2)}"
  secgroup = "${scaleway_security_group.nomad_server.id}"
  index = "3"
  expect_count = "${length(var.master_images)}"
  region = "${var.region}"
  domain = "${var.cloudflare_domain}"
}

resource "scaleway_security_group" "nomad_server" {
  name        = "nomad-server"
  description = "Nomad servers (masters)"
}

resource "scaleway_security_group_rule" "ssh_accept" {
  security_group = "${scaleway_security_group.nomad_server.id}"

  action    = "accept"
  direction = "inbound"
  ip_range  = "${var.management_ip}"
  protocol  = "TCP"
  port      = 22
}
resource "scaleway_security_group_rule" "nomad_accept" {
  security_group = "${scaleway_security_group.nomad_server.id}"

  action    = "accept"
  direction = "inbound"
  ip_range  = "${var.management_ip}"
  protocol  = "TCP"
  port      = 4646
}

resource "scaleway_security_group_rule" "drop_all_ssh" {
  security_group = "${scaleway_security_group.nomad_server.id}"
  depends_on = ["scaleway_security_group_rule.ssh_accept"]

  action    = "drop"
  direction = "inbound"
  ip_range  = "0.0.0.0/0"
  protocol  = "TCP"
  port = 22
}
resource "scaleway_security_group_rule" "drop_all_nomad" {
  security_group = "${scaleway_security_group.nomad_server.id}"
  depends_on = ["scaleway_security_group_rule.nomad_accept"]

  action    = "drop"
  direction = "inbound"
  ip_range  = "0.0.0.0/0"
  protocol  = "TCP"
  port = 4646
}
