variable "region" {}
variable "domain" {}
variable "image" {}
variable "index" {}
variable "secgroup" {}

variable "type" {
  default = "START1-XS"
}

variable "public_ip" {
  default = true
}

data "scaleway_image" "master" {
  architecture = "x86_64"
  name         = "${var.image}"
}

data "vault_approle_auth_backend_role_id" "role" {
  backend   = "approle"
  role_name = "nomad-role"
}

resource "scaleway_server" "nomad-agents" {
  name                = "nomad-agent-${var.index}"
  image               = "${data.scaleway_image.master.id}"
  dynamic_ip_required = "${var.public_ip}"
  enable_ipv6         = false
  type                = "${var.type}"
  boot_type           = "local"
  security_group      = "${var.secgroup}"
}

resource "scaleway_user_data" "count" {
  server = "${scaleway_server.nomad-agents.id}"
  key    = "COUNT"
  value  = "7"
}

resource "scaleway_user_data" "http_proxy" {
  server = "${scaleway_server.nomad-agents.id}"
  key    = "http_proxy"
  value  = "http://http.proxy.discovery.${var.region}.${var.domain}:3128"
}

resource "scaleway_user_data" "https_proxy" {
  server = "${scaleway_server.nomad-agents.id}"
  key    = "https_proxy"
  value  = "http://http.proxy.discovery.${var.region}.${var.domain}:3128"
}

resource "scaleway_user_data" "vault_addr" {
  server = "${scaleway_server.nomad-agents.id}"
  key    = "VAULT_ADDR"
  value  = "http://127.0.0.1:8200"
}

resource "scaleway_user_data" "vault_role" {
  server = "${scaleway_server.nomad-agents.id}"
  key    = "VAULT_ROLE_ID"
  value  = "${data.vault_approle_auth_backend_role_id.role.role_id}"
}

resource "scaleway_user_data" "vault_secret" {
  server = "${scaleway_server.nomad-agents.id}"
  key    = "VAULT_SECRET_ID"
  value  = "${vault_approle_auth_backend_role_secret_id.agents.secret_id}"
}

resource "scaleway_user_data" "vault_token_role" {
  server = "${scaleway_server.nomad-agents.id}"
  key    = "VAULT_TOKEN_ROLE"
  value  = "nomad-cluster"
}

resource "vault_approle_auth_backend_role_secret_id" "agents" {
  backend   = "approle"
  role_name = "nomad-role"
  cidr_list = ["${scaleway_server.nomad-agents.private_ip}/32"]
}

resource "cloudflare_record" "agents_discovery" {
  domain = "${var.domain}"
  name   = "agents.nomad.discovery.${var.region}"
  value  = "${scaleway_server.nomad-agents.private_ip}"
  type   = "A"
  ttl    = 1
}
