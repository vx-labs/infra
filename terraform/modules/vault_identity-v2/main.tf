variable "vault_role" {
  default = "instance"
}
variable "vault_token_role" {
  default = ""
}

variable "region" {}
variable "placement_group_id" {}
variable "domain" {}
variable "image" {}
variable "hostname" {}
variable "secgroup" {}
variable policies {
  type    = list(string)
  default = []
}
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

resource "vault_policy" "instance-identity" {
  name   = "identity-${var.hostname}"
  policy = <<EOT
path "auth/token/create/nomad-server" {
  capabilities = ["update", "create"]
}
path "pki/issue/${var.hostname}" {
  capabilities = ["create", "update"]
}
  EOT
}

resource "vault_pki_secret_backend_role" "instance-role" {
  backend            = "pki"
  name               = var.hostname
  allow_localhost    = false
  allow_bare_domains = true
  allowed_domains    = ["${var.hostname}.instance.discovery.cloud.vx-labs.net"]
  enforce_hostnames  = true
  ou                 = ["Instances"]
  require_cn         = true
  generate_lease     = true
  max_ttl            = "86400"
}

resource "vault_approle_auth_backend_role" "instance-role" {
  depends_on            = [vault_policy.instance-identity]
  role_name             = var.hostname
  secret_id_bound_cidrs = ["10.0.0.0/8"]
  secret_id_num_uses    = 0
  secret_id_ttl         = 0
  token_policies        = ["default", "identity-${var.hostname}"]
  token_period          = 600
}

module "instance" {
  source           = "../instance-v2"
  image            = var.image
  secgroup         = var.secgroup
  hostname         = var.hostname
  region           = var.region
  type             = var.type
  placement_group_id  = var.placement_group_id
  domain           = var.domain
  cloud_init       = var.cloud_init
  discovery_record = var.discovery_record
  public_ip        = var.public_ip
  ct_snippets      = [file("${path.module}/vault-ct.yaml")]
  user_data = concat([
    {
      key   = "VAULT_ROLE_ID"
      value = vault_approle_auth_backend_role.instance-role.role_id
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
  depends_on = [vault_approle_auth_backend_role.instance-role]
  backend    = "approle"
  role_name  = var.hostname
}

resource "vault_approle_auth_backend_role_secret_id" "secret" {
  depends_on = [vault_approle_auth_backend_role.instance-role]
  backend    = "approle"
  role_name  = var.hostname
  cidr_list  = ["10.0.0.0/8"]
}
