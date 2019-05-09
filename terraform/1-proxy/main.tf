module "proxy-1" {
  source           = "../modules/instance"
  image            = "${element(var.proxy_images, 0)}"
  secgroup         = "${scaleway_security_group.proxies.id}"
  hostname         = "proxy-1"
  region           = "${var.region}"
  domain           = "${var.cloudflare_domain}"
  cloudinit        = "${file("config.yaml")}"
  discovery_record = "servers.proxy"
  public_ip        = true
}

resource "scaleway_security_group" "proxies" {
  name        = "proxy"
  description = "Nomad servers (proxies)"
}

resource "scaleway_security_group_rule" "ssh_accept" {
  security_group = "${scaleway_security_group.proxies.id}"

  action    = "accept"
  direction = "inbound"
  ip_range  = "${var.management_ip}"
  protocol  = "TCP"
  port      = 22
}

resource "scaleway_security_group_rule" "drop_all_ssh" {
  security_group = "${scaleway_security_group.proxies.id}"
  depends_on     = ["scaleway_security_group_rule.ssh_accept"]

  action    = "drop"
  direction = "inbound"
  ip_range  = "0.0.0.0/0"
  protocol  = "TCP"
  port      = 22
}
