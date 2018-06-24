data "scaleway_image" "server" {
  architecture = "x86_64"
  name         = "coreos-nomad-server"
}
resource "scaleway_server" "nomad-server" {
  name  = "nomad-server"
  image = "${data.scaleway_image.server.id}"
  dynamic_ip_required = true
  enable_ipv6 = false
  type  = "START1-XS"
  count = "${var.master_count}"
  boot_type = "local"
  security_group = "${scaleway_security_group.nomad_server.id}"
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
output "cluster" {
value = "${join("\n",scaleway_server.nomad-server.*.public_ip)}"
}
