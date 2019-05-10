module "agent-1" {
  source           = "../modules/instance"
  image            = "${element(var.agent_images, 0)}"
  secgroup         = "${scaleway_security_group.nomad_agent.id}"
  hostname         = "nomad-agent-1"
  region           = "${var.region}"
  domain           = "${var.cloudflare_domain}"
  cloudinit        = "${file("config.yaml")}"
  discovery_record = "agents.nomad"
  user_data_count  = 5
}

module "agent-1-identity" {
  source              = "../modules/vault_identity"
  instance_id         = "${module.agent-1.instance_id}"
  instance_private_ip = "${module.agent-1.instance_private_ip}"
  vault_role          = "nomad-role"
  vault_token_role    = "nomad-cluster"
}

module "agent-2" {
  source           = "../modules/instance"
  image            = "${element(var.agent_images, 1)}"
  secgroup         = "${scaleway_security_group.nomad_agent.id}"
  hostname         = "nomad-agent-2"
  region           = "${var.region}"
  domain           = "${var.cloudflare_domain}"
  cloudinit        = "${file("config.yaml")}"
  discovery_record = "agents.nomad"
  user_data_count  = 5
}

module "agent-2-identity" {
  source              = "../modules/vault_identity"
  instance_id         = "${module.agent-2.instance_id}"
  instance_private_ip = "${module.agent-2.instance_private_ip}"
  vault_role          = "nomad-role"
  vault_token_role    = "nomad-cluster"
}

module "agent-3" {
  source           = "../modules/instance"
  image            = "${element(var.agent_images, 2)}"
  secgroup         = "${scaleway_security_group.nomad_agent.id}"
  hostname         = "nomad-agent-3"
  region           = "${var.region}"
  domain           = "${var.cloudflare_domain}"
  cloudinit        = "${file("config.yaml")}"
  discovery_record = "agents.nomad"
  user_data_count  = 5
}

module "agent-3-identity" {
  source              = "../modules/vault_identity"
  instance_id         = "${module.agent-3.instance_id}"
  instance_private_ip = "${module.agent-3.instance_private_ip}"
  vault_role          = "nomad-role"
  vault_token_role    = "nomad-cluster"
}
