resource "vault_pki_secret_backend" "pki" {
  path                      = "pki"
  default_lease_ttl_seconds = 3600
  max_lease_ttl_seconds     = 86400
}

resource "vault_pki_secret_backend_config_urls" "config_urls" {
  backend              = vault_pki_secret_backend.pki.path
  issuing_certificates = ["https://vault.cloud.${var.cloudflare_domain}/v1/pki/ca"]
}

resource "vault_pki_secret_backend_crl_config" "crl_config" {
  backend = vault_pki_secret_backend.pki.path
  expiry  = "72h"
  disable = false
}

resource "vault_pki_secret_backend_root_cert" "root_ca" {
  depends_on = [vault_pki_secret_backend.pki]

  backend = vault_pki_secret_backend.pki.path

  type                 = "internal"
  common_name          = "cloud.vx-labs.net"
  ttl                  = "315360000"
  format               = "pem"
  key_type             = "rsa"
  key_bits             = 4096
  exclude_cn_from_sans = true
  organization         = var.internal_ca_org
}

resource "vault_pki_secret_backend_role" "instance-role" {
  backend           = vault_pki_secret_backend.pki.path
  name              = "instance"
  allow_localhost   = false
  allowed_domains   = ["instance.discovery.cloud.vx-labs.net"]
  allow_subdomains  = true
  enforce_hostnames = true
  organization      = [var.internal_ca_org]
  ou                = ["Instances"]
  require_cn        = true
  generate_lease    = true
  max_ttl           = "86400"
}
