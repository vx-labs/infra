data "scaleway_image" "proxies" {
  count = "${length(var.proxy_images)}"
  architecture = "x86_64"
  name         = "${element(var.proxy_images, count.index)}"
}
resource "scaleway_server" "proxies" {
  count = "${length(var.proxy_images)}"
  name  = "proxy-${count.index}"
  image = "${element(data.scaleway_image.proxies.*.id, count.index)}"
  dynamic_ip_required = true
  enable_ipv6 = false
  type  = "START1-XS"
  boot_type = "local"
  security_group = "${scaleway_security_group.proxies.id}"
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
  depends_on = ["scaleway_security_group_rule.ssh_accept"]

  action    = "drop"
  direction = "inbound"
  ip_range  = "0.0.0.0/0"
  protocol  = "TCP"
  port = 22
}

