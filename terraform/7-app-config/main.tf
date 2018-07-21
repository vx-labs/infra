provider "vault" {}
provider "consul" {
}

variable "letsencrypt_email" {}
variable "mqtt_auth_tokens" {}

resource "consul_key_prefix" "mqtt_config" {
  path_prefix = "mqtt/conf/"

  subkeys = {
    "http"     = <<EOT
{
"proxy": "http://http.proxy.discovery.${var.region}.${var.cloudflare_domain}:3128"
}
EOT
    "tls"     = <<EOT
{
"cn": "broker.iot.cloud.${var.cloudflare_domain}",
"le_email": "${var.letsencrypt_email}"
}
EOT
  }
}

resource "vault_generic_secret" "mqtt-config" {
  path      = "/secret/data/mqtt/authentication"
  data_json = <<EOT
{
  "static_tokens": ["${join("\",\"", split(",", var.mqtt_auth_tokens))}"]
}
EOT
}

