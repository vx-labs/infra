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

resource "scaleway_user_data" "count" {
  count = "${length(var.coordinator_images)}"
  server = "${element(scaleway_server.coordinators.*.id, count.index)}"
  key = "COUNT"
  value = "3"
}

resource "scaleway_user_data" "consul_join_list" {
  count = "${length(var.coordinator_images)}"
  server = "${element(scaleway_server.coordinators.*.id, count.index)}"
  key = "CONSUL_JOIN_LIST"
  value = "${scaleway_server.coordinators.0.private_ip}"
}

resource "scaleway_user_data" "consul_cluster_size" {
  count = "${length(var.coordinator_images)}"
  server = "${element(scaleway_server.coordinators.*.id, count.index)}"
  key = "CONSUL_CLUSTER_SIZE"
  value = "${length(var.coordinator_images)}"
}

