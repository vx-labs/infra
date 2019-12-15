variable "vault_role" {}
variable "vault_token_role" {}

variable "region" {}
variable "domain" {}
variable "image" {}
variable "hostname" {}
variable "secgroup" {}
variable "user_data" {
  default = []
  type = list(object({
    key   = string
    value = string
  }))
}
variable "cloud_init" {
  default = ""
}

variable "type" {
  default = "START1-XS"
}

variable "public_ip" {
  default = false
}
variable "discovery_record" {}


module "instance" {
  source           = "../instance-v2"
  image            = var.image
  secgroup         = var.secgroup
  hostname         = var.hostname
  region           = var.region
  type             = var.type
  domain           = var.domain
  cloud_init       = var.cloud_init
  discovery_record = var.discovery_record
  public_ip        = var.public_ip
  user_data = concat([
    {
      key   = "VAULT_TOKEN_ROLE"
      value = var.vault_token_role
    },
    {
      key   = "VAULT_ROLE_ID"
      value = data.vault_approle_auth_backend_role_id.role.role_id
    },
    {
      key   = "VAULT_ROLE_ID"
      value = data.vault_approle_auth_backend_role_id.role.role_id
    },
    {
      key   = "VAULT_SECRET_ID"
      value = vault_approle_auth_backend_role_secret_id.secret.secret_id
    },
    {
      key   = "VAULT_ADDR"
      value = "http://active.vault.service.consul:8200"
    },
  ], var.user_data)
}

data "vault_approle_auth_backend_role_id" "role" {
  backend   = "approle"
  role_name = var.vault_role
}

resource "vault_approle_auth_backend_role_secret_id" "secret" {
  backend   = "approle"
  role_name = var.vault_role
  cidr_list = ["10.0.0.0/8"]
}
