data "scaleway_image" "server" {
  architecture = "x86_64"
  name         = "coreos-nomad-server"
}
resource "scaleway_server" "nomad-server" {
  lifecycle {
    create_before_destroy = true
  }
  name  = "nomad-server"
  image = "${data.scaleway_image.server.id}"
  dynamic_ip_required = true
  enable_ipv6 = false
  type  = "START1-XS"
  count = "${var.master_count}"
  boot_type = "local"
  security_group = "${scaleway_security_group.nomad_server.id}"
  tags  = [
    "CLUSTER_SIZE=${var.master_count}",
  ]
  provisioner "local-exec" {
    command = "docker run --rm quay.io/vxlabs/nomad-remove-local-peer server"
    when = "destroy"
    environment = {
      NOMAD_ADDR="http://${self.public_ip}:4646"
      CONSUL_HTTP_ADDR="${self.public_ip}:8500"
    }
  }
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
