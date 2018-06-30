variable "region" {}
variable "domain" {}
variable "image" {}
variable "index" {}
variable "secgroup" {}
variable "expect_count" {}

data "scaleway_image" "master" {
  architecture = "x86_64"
  name         = "${var.image}"
}

data "vault_approle_auth_backend_role_id" "role" {
  backend   = "approle"
  role_name = "nomad-role"
}

resource "scaleway_server" "nomad-masters" {
  name  = "nomad-master-${var.index}"
  image = "${data.scaleway_image.master.id}"
  dynamic_ip_required = true
  enable_ipv6 = false
  type  = "START1-XS"
  boot_type = "local"
  security_group = "${var.secgroup}"
}

resource "scaleway_user_data" "count" {
  server = "${scaleway_server.nomad-masters.id}"
  key = "COUNT"
  value = "6"
}

resource "scaleway_user_data" "cluster_size" {
  server = "${scaleway_server.nomad-masters.id}"
  key = "CLUSTER_SIZE"
  value = "${var.expect_count}"
}

resource "scaleway_user_data" "vault_addr" {
  server = "${scaleway_server.nomad-masters.id}"
  key = "VAULT_ADDR"
  value = "http://servers.vault.discovery.${var.region}.${var.domain}:8200"
}

resource "scaleway_user_data" "vault_role" {
  server = "${scaleway_server.nomad-masters.id}"
  key = "VAULT_ROLE_ID"
  value = "${data.vault_approle_auth_backend_role_id.role.role_id}"
}

resource "scaleway_user_data" "vault_secret" {
  server = "${scaleway_server.nomad-masters.id}"
  key = "VAULT_SECRET_ID"
  value = "${vault_approle_auth_backend_role_secret_id.masters.secret_id}"
}
resource "scaleway_user_data" "vault_token_role" {
  server = "${scaleway_server.nomad-masters.id}"
  key = "VAULT_TOKEN_ROLE"
  value = "nomad-cluster"
}

resource "vault_approle_auth_backend_role_secret_id" "masters" {
  backend   = "approle"
  role_name = "nomad-role"
  cidr_list  = ["${scaleway_server.nomad-masters.private_ip}/32"]
}

resource "cloudflare_record" "masters_discovery" {
  domain = "${var.domain}"
  name   = "servers.nomad.discovery.${var.region}"
  value  = "${scaleway_server.nomad-masters.private_ip}"
  type   = "A"
  ttl    = 1
}
resource "cloudflare_record" "nomad_servers_1" {
  domain = "${var.domain}"
  name   = "servers.nomad.${var.region}"
  value  = "${scaleway_server.nomad-masters.public_ip}"
  type   = "A"
  ttl    = 1
}
