data "scaleway_image" "coordinators" {
  count = "${length(var.coordinator_images)}"
  architecture = "x86_64"
  name         = "${element(var.coordinator_images, count.index)}"
}
resource "scaleway_server" "coordinators" {
  count = "${length(var.coordinator_images)}"
  name  = "coordinator-${count.index}"
  image = "${element(data.scaleway_image.coordinators.*.id, count.index)}"
  dynamic_ip_required = true
  enable_ipv6 = false
  type  = "START1-XS"
  boot_type = "local"
  security_group = "${scaleway_security_group.coordinators.id}"
  tags  = [
    "CLUSTER_SIZE=3",
  ]
}

resource "scaleway_security_group" "coordinators" {
  name        = "coordinator"
  description = "Nomad servers (coordinators)"
}

resource "scaleway_security_group_rule" "ssh_accept" {
  security_group = "${scaleway_security_group.coordinators.id}"

  action    = "accept"
  direction = "inbound"
  ip_range  = "${var.management_ip}"
  protocol  = "TCP"
  port      = 22
}
resource "scaleway_security_group_rule" "drop_all_ssh" {
  security_group = "${scaleway_security_group.coordinators.id}"
  depends_on = ["scaleway_security_group_rule.ssh_accept"]

  action    = "drop"
  direction = "inbound"
  ip_range  = "0.0.0.0/0"
  protocol  = "TCP"
  port = 22
}
