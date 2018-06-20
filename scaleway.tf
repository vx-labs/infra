variable "scw_api_organization" {}
variable "scw_api_token" {}
variable "region" {
  default = "par1"
}
data "scaleway_image" "agent" {
  architecture = "x86_64"
  name         = "coreos-nomad-agent"
}
data "scaleway_image" "server" {
  architecture = "x86_64"
  name         = "coreos-nomad-server"
}
data "scaleway_image" "lb" {
  architecture = "x86_64"
  name         = "coreos-nomad-lb"
}
provider "scaleway" {
  organization = "${var.scw_api_organization}"
  token        = "${var.scw_api_token}"
  region       = "${var.region}"
}

resource "scaleway_server" "nomad" {
  name  = "nomad"
  image = "${data.scaleway_image.server.id}"
  dynamic_ip_required = true
  enable_ipv6 = false
  type  = "START1-XS"
  count = "${var.master_count}"
  boot_type = "local"
  security_group = "${scaleway_security_group.private_ip.id}"
}
resource "scaleway_server" "nomad-agent" {
  name  = "nomad-agent"
  image = "${data.scaleway_image.agent.id}"
  dynamic_ip_required = true
  enable_ipv6 = false
  type  = "START1-XS"
  count = "${var.agent_count}"
  boot_type = "local"
  security_group = "${scaleway_security_group.private_ip.id}"
}
resource "scaleway_server" "nomad-lb" {
  name  = "nomad-lb"
  image = "${data.scaleway_image.lb.id}"
  dynamic_ip_required = true
  enable_ipv6 = false
  type  = "START1-XS"
  count  = "${var.lb_count}"
  boot_type = "local"
  security_group = "${scaleway_security_group.private_ip.id}"
}

resource "scaleway_security_group" "private_ip" {
  name        = "ssh"
  description = "allow SSH traffic from trusted IP"
}

resource "scaleway_security_group_rule" "ssh_accept" {
  security_group = "${scaleway_security_group.private_ip.id}"

  action    = "accept"
  direction = "inbound"
  ip_range  = "92.169.229.177"
  protocol  = "TCP"
  port      = 22
}
resource "scaleway_security_group_rule" "drop_all_ssh" {
  security_group = "${scaleway_security_group.private_ip.id}"
  depends_on = ["scaleway_security_group_rule.ssh_accept"]

  action    = "drop"
  direction = "inbound"
  ip_range  = "0.0.0.0/0"
  protocol  = "TCP"
  port = 22
}
resource "scaleway_security_group_rule" "consul_agent_accept" {
  security_group = "${scaleway_security_group.private_ip.id}"

  action    = "accept"
  direction = "inbound"
  ip_range  = "92.169.229.177"
  protocol  = "TCP"
  port      = 8500
}

resource "scaleway_security_group_rule" "drop_all_consul_agent" {
  security_group = "${scaleway_security_group.private_ip.id}"
  depends_on = ["scaleway_security_group_rule.consul_agent_accept"]

  action    = "drop"
  direction = "inbound"
  ip_range  = "0.0.0.0/0"
  protocol  = "TCP"
  port = 8500
}

resource "scaleway_security_group_rule" "nomad_accept" {
  security_group = "${scaleway_security_group.private_ip.id}"

  action    = "accept"
  direction = "inbound"
  ip_range  = "92.169.229.177"
  protocol  = "TCP"
  port      = 4646
}

resource "scaleway_security_group_rule" "drop_all_nomad" {
  security_group = "${scaleway_security_group.private_ip.id}"
  depends_on = ["scaleway_security_group_rule.nomad_accept"]

  action    = "drop"
  direction = "inbound"
  ip_range  = "0.0.0.0/0"
  protocol  = "TCP"
  port = 4646
}



output "cluster" {
value = "${join("\n",scaleway_server.nomad.*.public_ip)}"
}
