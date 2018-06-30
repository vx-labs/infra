provider "vault" {}

data "scaleway_image" "masters" {
  count = "${length(var.master_images)}"
  architecture = "x86_64"
  name         = "${element(var.master_images, count.index)}"
}

data "vault_approle_auth_backend_role_id" "role" {
  backend   = "approle"
  role_name = "nomad-role"
}

resource "scaleway_server" "nomad-masters" {
  count = "${length(var.master_images)}"
  name  = "nomad-master-${count.index}"
  image = "${element(data.scaleway_image.masters.*.id, count.index)}"
  dynamic_ip_required = true
  enable_ipv6 = false
  type  = "START1-XS"
  boot_type = "local"
  security_group = "${scaleway_security_group.nomad_server.id}"
  tags  = [
    "CLUSTER_SIZE=${length(var.master_images)}",
  ]
}

resource "scaleway_user_data" "count" {
  count = "${length(var.master_images)}"
  server = "${element(scaleway_server.nomad-masters.*.id, count.index)}"
  key = "COUNT"
  value = "4"
}

resource "scaleway_user_data" "vault_addr" {
  count = "${length(var.master_images)}"
  server = "${element(scaleway_server.nomad-masters.*.id, count.index)}"
  key = "VAULT_ADDR"
  value = "http://servers.vault.discovery.${var.region}.${var.cloudflare_domain}:8200"
}

resource "scaleway_user_data" "vault_role" {
  count = "${length(var.master_images)}"
  server = "${element(scaleway_server.nomad-masters.*.id, count.index)}"
  key = "VAULT_ROLE_ID"
  value = "${data.vault_approle_auth_backend_role_id.role.role_id}"
}

resource "scaleway_user_data" "vault_secret" {
  count = "${length(var.master_images)}"
  server = "${element(scaleway_server.nomad-masters.*.id, count.index)}"
  key = "VAULT_SECRET_ID"
  value = "${element(vault_approle_auth_backend_role_secret_id.masters.*.secret_id, count.index)}"
}
resource "scaleway_user_data" "vault_token_role" {
  count = "${length(var.master_images)}"
  server = "${element(scaleway_server.nomad-masters.*.id, count.index)}"
  key = "VAULT_TOKEN_ROLE"
  value = "nomad-cluster"
}

resource "vault_approle_auth_backend_role_secret_id" "masters" {
  count = "${length(var.master_images)}"
  backend   = "approle"
  role_name = "nomad-role"
  cidr_list  = ["${element(scaleway_server.nomad-masters.*.private_ip, count.index)}/32"]
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
