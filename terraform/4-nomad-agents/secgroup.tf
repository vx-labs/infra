resource "scaleway_security_group" "nomad_agent" {
  name        = "nomad-server"
  description = "Nomad servers (agents)"
}

resource "scaleway_security_group_rule" "ssh_accept" {
  security_group = "${scaleway_security_group.nomad_agent.id}"

  action    = "accept"
  direction = "inbound"
  ip_range  = "${var.management_ip}"
  protocol  = "TCP"
  port      = 22
}
resource "scaleway_security_group_rule" "drop_all_ssh" {
  security_group = "${scaleway_security_group.nomad_agent.id}"
  depends_on = ["scaleway_security_group_rule.ssh_accept"]

  action    = "drop"
  direction = "inbound"
  ip_range  = "0.0.0.0/0"
  protocol  = "TCP"
  port = 22
}

