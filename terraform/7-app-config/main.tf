provider "vault" {}
provider "consul" {}

provider "nomad" {}

variable "mqtt_auth_tokens" {}
variable "mqtt_signing_token" {}
variable "tracing_es_url" {}
variable "tracing_es_username" {}
variable "tracing_es_password" {}

resource "consul_key_prefix" "mqtt_config" {
  path_prefix = "mqtt/conf/"

  subkeys = {
    "http" = <<EOT
{
"proxy": "http://http.proxy.discovery.${var.region}.${var.cloudflare_domain}:3128"
}
EOT

    "tls" = <<EOT
{
"cn": "broker.iot.cloud.${var.cloudflare_domain}",
"le_email": "${var.letsencrypt_email}"
}
EOT
  }
}

resource "vault_generic_secret" "mqtt-config" {
  path = "/secret/data/mqtt/authentication"

  data_json = <<EOT
{
"static_tokens": "${var.mqtt_auth_tokens}",
"signing_token": "${var.mqtt_signing_token}"
}
EOT
}

resource "vault_generic_secret" "tracing-config" {
  path = "/secret/data/tracing/es"

  data_json = <<EOT
{
"url": "${var.tracing_es_url}",
"username": "${var.tracing_es_username}",
"password": "${var.tracing_es_password}"
}
EOT
}

resource "vault_generic_secret" "vx-dashboards" {
  path = "/secret/data/vx/grafana"

  data_json = <<EOT
{
  "nomad": "${filebase64("dashboards/nomad.json")}"
}
EOT
}
