provider "vault" {}

resource "vault_policy" "nomad-server" {
  name   = "nomad-server"
  policy = "${file("nomad-server-policy.hcl")}"
}

resource "vault_policy" "nomad-tls-storer" {
  name   = "nomad-tls-storer"
  policy = "${file("nomad-tls-storer-policy.hcl")}"
}

resource "vault_policy" "nomad-logzio-shipper" {
  name   = "nomad-logzio-shipper"
  policy = "${file("nomad-logzio-shipper-policy.hcl")}"
}

resource "vault_policy" "nomad-grafana" {
  name   = "nomad-grafana"
  policy = "${file("nomad-grafana-policy.hcl")}"
}

resource "vault_policy" "nomad-datadog-shipper" {
  name   = "nomad-datadog-shipper"
  policy = "${file("nomad-datadog-shipper-policy.hcl")}"
}

resource "vault_policy" "nomad-es-helper" {
  name   = "nomad-es-helper"
  policy = "${file("nomad-es-helper-policy.hcl")}"
}

resource "vault_policy" "nomad-authenticator" {
  name   = "nomad-authenticator"
  policy = "${file("nomad-authenticator-policy.hcl")}"
}
resource "vault_generic_secret" "nomad-token-role" {
  path      = "/auth/token/roles/nomad-cluster"
  data_json = <<EOT
{
  "disallowed_policies": "nomad-server",
  "explicit_max_ttl": 0,
  "name": "nomad-cluster",
  "orphan": true,
  "period": 259200,
  "renewable": true
}
  EOT
}

resource "vault_generic_secret" "nomad-server-role" {
  path      = "/auth/token/roles/nomad-server"
  data_json = <<EOT
{
  "disallowed_policies": "instance",
  "explicit_max_ttl": 0,
  "name": "nomad-server",
  "orphan": true,
  "period": 259200,
  "renewable": true
}
  EOT
}

resource "vault_auth_backend" "approle" {
  type = "approle"
}

resource "vault_approle_auth_backend_role" "nomad-agent" {
  depends_on         = [vault_policy.nomad-server]
  role_name          = "nomad-role"
  bound_cidr_list    = ["10.0.0.0/8"]
  secret_id_num_uses = 0
  secret_id_ttl      = 0
  policies           = ["default", "nomad-server"]
  period             = 600
}

resource "vault_generic_secret" "vx-cloudflare" {
  path = "/secret/data/vx/cloudflare"

  data_json = <<EOT
{
  "email": "${var.cloudflare_email}",
  "api_token": "${var.cloudflare_token}"
}
EOT
}

resource "vault_generic_secret" "vx-datadog" {
  path = "/secret/data/vx/datadog"

  data_json = <<EOT
{
  "api_token": "${var.datadog_token}"
}
EOT
}

resource "vault_generic_secret" "vx-logzio" {
  path = "/secret/data/vx/logzio"

  data_json = <<EOT
{
  "token": "${var.logzio_token}"
}
EOT
}

resource "vault_generic_secret" "vx-config" {
  path = "/secret/data/vx/mqtt"

  data_json = <<EOT
{
  "http_proxy": "http://http.proxy.discovery.par1.vx-labs.net:3128",
  "jwt_sign_key": "${var.jwt_sign_key}",
  "acme_email": "julien@bonachera.fr"
}
EOT
}
