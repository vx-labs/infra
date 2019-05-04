variable "region" {}
variable "domain" {}
variable "image" {}
variable "index" {}
variable "secgroup" {}
variable "expect_count" {}
variable "type" {
  default = "DEV1-S"
}

variable "public_ip" {
  default = true
}

data "scaleway_image" "master" {
  architecture = "x86_64"
  name         = "${var.image}"
}

resource "scaleway_server" "coordinator" {
  name                = "coordinator-${var.index}-ng"
  image               = "${data.scaleway_image.master.id}"
  dynamic_ip_required = "${var.public_ip}"
  enable_ipv6         = false
  type                = "${var.type}"
  boot_type           = "local"
  security_group      = "${var.secgroup}"
}

resource "scaleway_user_data" "count" {
  server = "${scaleway_server.coordinator.id}"
  key    = "COUNT"
  value  = "5"
}

resource "scaleway_user_data" "consul_cluster_size" {
  server = "${scaleway_server.coordinator.id}"
  key    = "CONSUL_CLUSTER_SIZE"
  value  = "${var.expect_count}"
}

resource "scaleway_user_data" "http_proxy" {
  server = "${scaleway_server.coordinator.id}"
  key    = "http_proxy"
  value  = "http://http.proxy.discovery.${var.region}.${var.domain}:3128"
}

resource "scaleway_user_data" "https_proxy" {
  server = "${scaleway_server.coordinator.id}"
  key    = "https_proxy"
  value  = "http://http.proxy.discovery.${var.region}.${var.domain}:3128"
}

resource "cloudflare_record" "consul-discovery" {
  domain = "${var.domain}"
  name   = "servers.consul.discovery.${var.region}"
  value  = "${scaleway_server.coordinator.private_ip}"
  type   = "A"
  ttl    = 1
}

resource "cloudflare_record" "vault-discovery" {
  domain = "${var.domain}"
  name   = "servers.vault.discovery.${var.region}"
  value  = "${scaleway_server.coordinator.private_ip}"
  type   = "A"
  ttl    = 1
}

output "server_id" {
  value = "${scaleway_server.coordinator.id}"
}

output "private_ip" {
  value = "${scaleway_server.coordinator.private_ip}"
}
