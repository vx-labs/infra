variable "instance_id" {}
variable "instance_private_ip" {}
variable "vault_role" {}
variable "vault_token_role" {}

data "vault_approle_auth_backend_role_id" "role" {
  backend   = "approle"
  role_name = "${var.vault_role}"
}

resource "scaleway_user_data" "vault_token_role" {
  server = "${var.instance_id}"
  key    = "VAULT_TOKEN_ROLE"
  value  = "${var.vault_token_role}"
}

resource "vault_approle_auth_backend_role_secret_id" "secret" {
  backend   = "approle"
  role_name = "${var.vault_role}"
  cidr_list = ["${var.instance_private_ip}/32"]
}

resource "scaleway_user_data" "vault_role" {
  server = "${var.instance_id}"
  key    = "VAULT_ROLE_ID"
  value  = "${data.vault_approle_auth_backend_role_id.role.role_id}"
}

resource "scaleway_user_data" "vault_secret" {
  server = "${var.instance_id}"
  key    = "VAULT_SECRET_ID"
  value  = "${vault_approle_auth_backend_role_secret_id.secret.secret_id}"
}

resource "scaleway_user_data" "vault_addr" {
  server = "${var.instance_id}"
  key    = "VAULT_ADDR"
  value  = "http://localhost:8200"
}

output "ud_count" {
  value = "5"
}
