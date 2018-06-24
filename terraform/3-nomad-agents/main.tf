provider "vault" {}

data "scaleway_image" "agent" {
  architecture = "x86_64"
  name         = "coreos-nomad-agent"
}

resource "random_id" "secret_id" {
  count = "${var.agent_count}"
  keepers = {
    ami_id = "${data.scaleway_image.agent.id}"
  }
  byte_length = 16
}

data "vault_approle_auth_backend_role_id" "role" {
  backend   = "approle"
  role_name = "nomad-agent"
}

resource "scaleway_server" "nomad-agent" {
  count = "${var.agent_count}"
  name  = "nomad-agent"
  image = "${data.scaleway_image.agent.id}"
  dynamic_ip_required = true
  enable_ipv6 = false
  type  = "START1-XS"
  boot_type = "local"
  security_group = "${scaleway_security_group.nomad_agent.id}"
  tags  = [
    "VAULT_ROLE_ID=${data.vault_approle_auth_backend_role_id.role.id}",
    "VAULT_SECRET_ID=${element(random_id.secret_id.*.hex, count.index)}"
  ]
}

resource "vault_approle_auth_backend_role_secret_id" "id" {
  count     = "${var.agent_count}"
  secret_id = "${element(random_id.secret_id.*.hex, count.index)}"
  backend   = "approle"
  role_name = "nomad-agent"
}
