data "scaleway_image" "lb" {
  architecture = "x86_64"
  name         = "${element(var.lb_images, 0)}"
}

resource "scaleway_ip" "nomad-lb-ip" {
  server = "${element(scaleway_server.nomad-lb.*.id, count.index)}"
  count  = "${var.lb_count}"
}

resource "scaleway_server" "nomad-lb" {
  name                = "nomad-lb"
  image               = "${data.scaleway_image.lb.id}"
  dynamic_ip_required = false
  enable_ipv6         = false
  type                = "START1-XS"
  count               = "${var.lb_count}"
  boot_type           = "local"
  security_group      = "${scaleway_security_group.nomad_lb.id}"
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
