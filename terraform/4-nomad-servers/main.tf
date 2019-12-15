module "server-1" {
  source           = "../modules/vault_identity-v2"
  vault_role       = "nomad-role"
  vault_token_role = "nomad-cluster"
  image            = element(var.master_images, 0)
  secgroup         = scaleway_security_group.nomad_server.id
  hostname         = "nomad-server-1"
  region           = var.region
  domain           = var.cloudflare_domain
  cloud_init       = file("config.yaml")
  discovery_record = "servers.nomad"

  user_data = [{
    key   = "CONSUL_JOIN_LIST"
    value = "servers.consul.discovery.${var.region}.${var.cloudflare_domain}"
    }, {
    key   = "CLUSTER_SIZE"
    value = length(var.master_images)
  }]
}
module "server-2" {
  source           = "../modules/vault_identity-v2"
  vault_role       = "nomad-role"
  vault_token_role = "nomad-cluster"
  image            = element(var.master_images, 1)
  secgroup         = scaleway_security_group.nomad_server.id
  hostname         = "nomad-server-2"
  region           = var.region
  domain           = var.cloudflare_domain
  cloud_init       = file("config.yaml")
  discovery_record = "servers.nomad"

  user_data = [{
    key   = "CONSUL_JOIN_LIST"
    value = "servers.consul.discovery.${var.region}.${var.cloudflare_domain}"
    }, {
    key   = "CLUSTER_SIZE"
    value = length(var.master_images)
  }]
}



module "server-3" {
  source           = "../modules/vault_identity-v2"
  vault_role       = "nomad-role"
  vault_token_role = "nomad-cluster"
  image            = element(var.master_images, 2)
  secgroup         = scaleway_security_group.nomad_server.id
  hostname         = "nomad-server-3"
  region           = var.region
  domain           = var.cloudflare_domain
  cloud_init       = file("config.yaml")
  discovery_record = "servers.nomad"

  user_data = [{
    key   = "CONSUL_JOIN_LIST"
    value = "servers.consul.discovery.${var.region}.${var.cloudflare_domain}"
    }, {
    key   = "CLUSTER_SIZE"
    value = length(var.master_images)
  }]
}


resource "scaleway_security_group" "nomad_server" {
  name        = "nomad-server"
  description = "Nomad servers (masters)"
}
