variable "region" {}
variable "domain" {}
variable "image" {}
variable "index" {}
variable "secgroup" {}
variable "expect_count" {}

variable "public_ip" {
  default = true
}

data "scaleway_image" "nats" {
  architecture = "x86_64"
  name         = "${var.image}"
}

data "vault_approle_auth_backend_role_id" "role" {
  backend   = "approle"
  role_name = "nomad-role"
}

resource "scaleway_server" "nats" {
  name                = "nomad-nats-${var.index}"
  image               = "${data.scaleway_image.nats.id}"
  dynamic_ip_required = "${var.public_ip}"
  enable_ipv6         = false
  type                = "START1-XS"
  boot_type           = "local"
  security_group      = "${var.secgroup}"
}

resource "scaleway_user_data" "count" {
  server = "${scaleway_server.nats.id}"
  key    = "COUNT"
  value  = "11"
}

resource "scaleway_user_data" "http_proxy" {
  server = "${scaleway_server.nats.id}"
  key    = "http_proxy"
  value  = "http://http.proxy.discovery.${var.region}.${var.domain}:3128"
}

resource "scaleway_user_data" "https_proxy" {
  server = "${scaleway_server.nats.id}"
  key    = "https_proxy"
  value  = "http://http.proxy.discovery.${var.region}.${var.domain}:3128"
}

resource "scaleway_user_data" "cluster_size" {
  server = "${scaleway_server.nats.id}"
  key    = "CLUSTER_SIZE"
  value  = "${var.expect_count}"
}

resource "scaleway_user_data" "vault_addr" {
  server = "${scaleway_server.nats.id}"
  key    = "VAULT_ADDR"
  value  = "http://127.0.0.1:8200"
}

resource "scaleway_user_data" "vault_role" {
  server = "${scaleway_server.nats.id}"
  key    = "VAULT_ROLE_ID"
  value  = "${data.vault_approle_auth_backend_role_id.role.role_id}"
}

resource "scaleway_user_data" "vault_secret" {
  server = "${scaleway_server.nats.id}"
  key    = "VAULT_SECRET_ID"
  value  = "${vault_approle_auth_backend_role_secret_id.nats.secret_id}"
}

resource "scaleway_user_data" "vault_token_role" {
  server = "${scaleway_server.nats.id}"
  key    = "VAULT_TOKEN_ROLE"
  value  = "nomad-cluster"
}

resource "scaleway_user_data" "nats-id" {
  server = "${scaleway_server.nats.id}"
  key    = "NATS_ID"
  value  = "${var.index}"
}

resource "scaleway_user_data" "nats-peers" {
  server = "${scaleway_server.nats.id}"
  key    = "NATS_PEERS"
  value  = "1,2,3"
}

resource "vault_approle_auth_backend_role_secret_id" "nats" {
  backend   = "approle"
  role_name = "nomad-role"
  cidr_list = ["${scaleway_server.nats.private_ip}/32"]
}

resource "cloudflare_record" "nats_direct_discovery" {
  domain = "${var.domain}"
  name   = "${var.index}.servers.nats.discovery.${var.region}"
  value  = "${scaleway_server.nats.private_ip}"
  type   = "A"
  ttl    = 1
}

resource "cloudflare_record" "nats_discovery" {
  domain = "${var.domain}"
  name   = "servers.nats.discovery.${var.region}"
  value  = "${scaleway_server.nats.private_ip}"
  type   = "A"
  ttl    = 1
}

output "server_id" {
  value = "${scaleway_server.nats.id}"
}

output "server_private_ip" {
  value = "${scaleway_server.nats.private_ip}"
}
