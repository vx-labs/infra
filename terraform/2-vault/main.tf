provider "vault" {}

resource "vault_policy" "nomad-server" {
  name = "nomad-server"
  policy = "${file("nomad-server-policy.hcl")}"
}
resource "vault_policy" "nomad-tls-storer" {
  name = "nomad-tls-storer"
  policy = "${file("nomad-tls-storer-policy.hcl")}"
}
resource "vault_auth_backend" "approle" {
  type = "approle"
}
resource "vault_approle_auth_backend_role" "nomad-agent" {
  depends_on = ["vault_policy.nomad-server"]
  role_name = "nomad-role"
  bound_cidr_list = ["10.0.0.0/0"]
  secret_id_num_uses = 1
  secret_id_ttl = 600
  token_ttl = 259200
  policies  = ["nomad-server"]
  period    = true
}
