resource "scaleway_instance_placement_group" "availability_group" {
  name        = "nomad-agents"
  policy_mode = "enforced"
}
module "agent-1" {
  source             = "../modules/vault_identity-v2"
  vault_role         = "nomad-role"
  vault_token_role   = "nomad-cluster"
  image              = element(var.agent_images, 0)
  secgroup           = scaleway_instance_security_group.nomad_agent.id
  hostname           = "nomad-agent-1"
  region             = var.region
  type               = "DEV1-S"
  domain             = var.cloudflare_domain
  placement_group_id = scaleway_instance_placement_group.availability_group.id
  cloud_init         = file("config.yaml")
  discovery_record   = "agents.nomad"

  user_data = [{
    key   = "CONSUL_JOIN_LIST"
    value = "servers.consul.discovery.${var.region}.${var.cloudflare_domain}"
  }]
}

module "agent-2" {
  source             = "../modules/vault_identity-v2"
  vault_role         = "nomad-role"
  vault_token_role   = "nomad-cluster"
  image              = element(var.agent_images, 0)
  secgroup           = scaleway_instance_security_group.nomad_agent.id
  hostname           = "nomad-agent-2"
  region             = var.region
  type               = "DEV1-S"
  domain             = var.cloudflare_domain
  placement_group_id = scaleway_instance_placement_group.availability_group.id
  cloud_init         = file("config.yaml")
  discovery_record   = "agents.nomad"

  user_data = [{
    key   = "CONSUL_JOIN_LIST"
    value = "servers.consul.discovery.${var.region}.${var.cloudflare_domain}"
  }]
}


module "agent-3" {
  source             = "../modules/vault_identity-v2"
  vault_role         = "nomad-role"
  vault_token_role   = "nomad-cluster"
  image              = element(var.agent_images, 0)
  secgroup           = scaleway_instance_security_group.nomad_agent.id
  hostname           = "nomad-agent-3"
  region             = var.region
  type               = "DEV1-S"
  domain             = var.cloudflare_domain
  placement_group_id = scaleway_instance_placement_group.availability_group.id
  cloud_init         = file("config.yaml")
  discovery_record   = "agents.nomad"

  user_data = [{
    key   = "CONSUL_JOIN_LIST"
    value = "servers.consul.discovery.${var.region}.${var.cloudflare_domain}"
  }]
}

module "agent-4" {
  source             = "../modules/vault_identity-v2"
  vault_role         = "nomad-role"
  vault_token_role   = "nomad-cluster"
  image              = element(var.agent_images, 0)
  secgroup           = scaleway_instance_security_group.nomad_agent.id
  hostname           = "nomad-agent-4"
  region             = var.region
  type               = "DEV1-S"
  domain             = var.cloudflare_domain
  placement_group_id = scaleway_instance_placement_group.availability_group.id
  cloud_init         = file("config.yaml")
  discovery_record   = "agents.nomad"

  user_data = [{
    key   = "CONSUL_JOIN_LIST"
    value = "servers.consul.discovery.${var.region}.${var.cloudflare_domain}"
  }]
}
