variable "region" {}
variable "domain" {}
variable "image" {}
variable "hostname" {}
variable "secgroup" {}
variable "vault_token_role" {}
variable "vault_role" {}

variable "user_data_count" {
  default = 0
}

variable "cloudinit" {
  default = ""
}

variable "type" {
  default = "START1-XS"
}

variable "public_ip" {
  default = false
}
variable "discovery_record" {}

data "scaleway_image" "master" {
  architecture = "x86_64"
  name         = "${var.image}"
}

data "ct_config" "instance" {
  content      = "${var.cloudinit}"
  platform     = "custom"
  pretty_print = false

  snippets = [
    <<EOF
storage:
  files:
    - filesystem: "root"
      path:       "/etc/hostname"
      mode:       0644
      contents:
        inline: ${var.hostname}
EOF
    ,
  ]
}

resource "scaleway_server" "instance" {
  name                = "${var.hostname}"
  image               = "${data.scaleway_image.master.id}"
  dynamic_ip_required = "${var.public_ip}"
  enable_ipv6         = false
  type                = "${var.type}"
  boot_type           = "local"
  security_group      = "${var.secgroup}"
  cloudinit           = "${data.ct_config.instance.rendered}"
}

resource "scaleway_user_data" "http_proxy" {
  server = "${scaleway_server.instance.id}"
  key    = "http_proxy"
  value  = "http://http.proxy.discovery.${var.region}.${var.domain}:3128"
}

resource "scaleway_user_data" "https_proxy" {
  server = "${scaleway_server.instance.id}"
  key    = "https_proxy"
  value  = "http://http.proxy.discovery.${var.region}.${var.domain}:3128"
}

resource "scaleway_user_data" "vault_addr" {
  server = "${scaleway_server.instance.id}"
  key    = "VAULT_ADDR"
  value  = "http://127.0.0.1:8200"
}

resource "scaleway_user_data" "vault_role" {
  server = "${scaleway_server.instance.id}"
  key    = "VAULT_ROLE_ID"
  value  = "${data.vault_approle_auth_backend_role_id.role.role_id}"
}

resource "scaleway_user_data" "vault_secret" {
  server = "${scaleway_server.instance.id}"
  key    = "VAULT_SECRET_ID"
  value  = "${vault_approle_auth_backend_role_secret_id.secret.secret_id}"
}

data "vault_approle_auth_backend_role_id" "role" {
  backend   = "approle"
  role_name = "${var.vault_role}"
}

resource "scaleway_user_data" "vault_token_role" {
  server = "${scaleway_server.instance.id}"
  key    = "VAULT_TOKEN_ROLE"
  value  = "${var.vault_token_role}"
}

resource "vault_approle_auth_backend_role_secret_id" "secret" {
  backend   = "approle"
  role_name = "${var.vault_role}"
  cidr_list = ["${scaleway_server.instance.private_ip}/32"]
}

resource "scaleway_user_data" "agent_1_count" {
  server = "${scaleway_server.instance.id}"
  key    = "COUNT"
  value  = "${format("%d", 7 + var.user_data_count)}"
}

resource "cloudflare_record" "discovery_record" {
  domain = "${var.domain}"
  name   = "${var.discovery_record}.discovery.${var.region}"
  value  = "${scaleway_server.instance.private_ip}"
  type   = "A"
  ttl    = 1
}
resource "cloudflare_record" "hostname_record" {
  domain = "${var.domain}"
  name   = "${var.hostname}.instance.discovery.${var.region}"
  value  = "${scaleway_server.instance.private_ip}"
  type   = "A"
  ttl    = 1
}


output "instance_id" {
  value = "${scaleway_server.instance.id}"
}

output "instance_private_ip" {
  value = "${scaleway_server.instance.private_ip}"
}

output "instance_public_ip" {
  value = "${scaleway_server.instance.public_ip}"
}
