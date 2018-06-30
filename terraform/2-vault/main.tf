provider "vault" {}

resource "vault_policy" "nomad-server" {
  name = "nomad-server"
  policy = "${file("nomad-server-policy.hcl")}"
}
resource "vault_policy" "nomad-tls-storer" {
  name = "nomad-tls-storer"
  policy = "${file("nomad-tls-storer-policy.hcl")}"
}
resource "vault_generic_secret" "nomad-token-role" {
  path      = "/auth/token/roles/nomad-cluster"
  data_json = "${file("nomad-cluster-role.json")}"
}
resource "vault_auth_backend" "approle" {
  type = "approle"
}
resource "vault_approle_auth_backend_role" "nomad-agent" {
  depends_on = ["vault_policy.nomad-server"]
  role_name = "nomad-role"
  bound_cidr_list = ["10.0.0.0/8"]
  secret_id_num_uses = 0
  secret_id_ttl = 0
  policies  = ["default", "nomad-server"]
  period    = 600
}
