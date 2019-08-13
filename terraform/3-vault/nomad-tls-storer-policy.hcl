path "secret/data/mqtt/acme/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}
path "secret/data/vx/mqtt" {
  capabilities = ["read"]
}

path "secret/data/mqtt/tls-staging/account/registration" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "secret/data/mqtt/tls-staging/account/private_key" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "secret/data/mqtt/tls-staging/broker.iot.cloud.vx-labs.net/private_key" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "secret/data/mqtt/tls-staging/broker.iot.cloud.vx-labs.net/certificate" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "secret/data/mqtt/tls-staging/broker-api.iot.cloud.vx-labs.net/private_key" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "secret/data/mqtt/tls-staging/broker-api.iot.cloud.vx-labs.net/certificate" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "secret/data/mqtt/tls-staging/mqtt.iot.cloud.vx-labs.net/private_key" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "secret/data/mqtt/tls-staging/mqtt.iot.cloud.vx-labs.net/certificate" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "secret/data/mqtt/tls/account/registration" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "secret/data/mqtt/tls/account/private_key" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "secret/data/mqtt/tls/broker.iot.cloud.vx-labs.net/private_key" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "secret/data/mqtt/tls/broker.iot.cloud.vx-labs.net/certificate" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "secret/data/mqtt/tls/broker-api.iot.cloud.vx-labs.net/private_key" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "secret/data/mqtt/tls/broker-api.iot.cloud.vx-labs.net/certificate" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "secret/data/mqtt/tls/mqtt.iot.cloud.vx-labs.net/private_key" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "secret/data/mqtt/tls/mqtt.iot.cloud.vx-labs.net/certificate" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "secret/data/vx/cloudflare" {
  capabilities = ["read"]
}
