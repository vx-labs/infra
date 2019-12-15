module "agent-1" {
  source           = "../modules/instance"
  image            = "${element(var.agent_images, 0)}"
  secgroup         = "${scaleway_security_group.nomad_agent.id}"
  hostname         = "nomad-agent-1"
  region           = "${var.region}"
  type             = "DEV1-S"
  domain           = "${var.cloudflare_domain}"
  cloudinit        = "${file("config.yaml")}"
  discovery_record = "agents.nomad"
  user_data_count  = 6
}

module "agent-1-identity" {
  source              = "../modules/vault_identity"
  instance_id         = "${module.agent-1.instance_id}"
  instance_private_ip = "${module.agent-1.instance_private_ip}"
  vault_role          = "nomad-role"
  vault_token_role    = "nomad-cluster"
}

resource "scaleway_user_data" "consul_join_list_1" {
  server = module.agent-1.instance_id
  key    = "CONSUL_JOIN_LIST"
  value  = "servers.consul.discovery.${var.region}.${var.cloudflare_domain}"
}

module "agent-2" {
  source           = "../modules/instance"
  image            = "${element(var.agent_images, 1)}"
  secgroup         = "${scaleway_security_group.nomad_agent.id}"
  hostname         = "nomad-agent-2"
  region           = "${var.region}"
  type             = "DEV1-S"
  domain           = "${var.cloudflare_domain}"
  cloudinit        = "${file("config.yaml")}"
  discovery_record = "agents.nomad"
  user_data_count  = 6
}

module "agent-2-identity" {
  source              = "../modules/vault_identity"
  instance_id         = "${module.agent-2.instance_id}"
  instance_private_ip = "${module.agent-2.instance_private_ip}"
  vault_role          = "nomad-role"
  vault_token_role    = "nomad-cluster"
}

resource "scaleway_user_data" "consul_join_list_2" {
  server = module.agent-2.instance_id
  key    = "CONSUL_JOIN_LIST"
  value  = "servers.consul.discovery.${var.region}.${var.cloudflare_domain}"
}

module "agent-3" {
  source           = "../modules/instance"
  image            = "${element(var.agent_images, 2)}"
  secgroup         = "${scaleway_security_group.nomad_agent.id}"
  hostname         = "nomad-agent-3"
  region           = "${var.region}"
  type             = "DEV1-S"
  domain           = "${var.cloudflare_domain}"
  cloudinit        = "${file("config.yaml")}"
  discovery_record = "agents.nomad"
  user_data_count  = 6
}

module "agent-3-identity" {
  source              = "../modules/vault_identity"
  instance_id         = "${module.agent-3.instance_id}"
  instance_private_ip = "${module.agent-3.instance_private_ip}"
  vault_role          = "nomad-role"
  vault_token_role    = "nomad-cluster"
}
resource "scaleway_user_data" "consul_join_list_3" {
  server = module.agent-3.instance_id
  key    = "CONSUL_JOIN_LIST"
  value  = "servers.consul.discovery.${var.region}.${var.cloudflare_domain}"
}