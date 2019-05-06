provider "vault" {}

data "ct_config" "agent" {
  content      = "${file("config.yaml")}"
  platform     = "custom"
  pretty_print = false
}

module "agent-1" {
  source    = "./modules/nomad-agent"
  image     = "${element(var.agent_images, 0)}"
  secgroup  = "${scaleway_security_group.nomad_agent.id}"
  index     = "1"
  region    = "${var.region}"
  domain    = "${var.cloudflare_domain}"
  public_ip = false
  cloudinit = "${data.ct_config.agent.rendered}"
}

module "agent-2" {
  source    = "./modules/nomad-agent"
  image     = "${element(var.agent_images, 1)}"
  secgroup  = "${scaleway_security_group.nomad_agent.id}"
  index     = "2"
  region    = "${var.region}"
  domain    = "${var.cloudflare_domain}"
  public_ip = false
  cloudinit = "${data.ct_config.agent.rendered}"
}

module "agent-3" {
  source    = "./modules/nomad-agent"
  image     = "${element(var.agent_images, 2)}"
  secgroup  = "${scaleway_security_group.nomad_agent.id}"
  index     = "3"
  region    = "${var.region}"
  domain    = "${var.cloudflare_domain}"
  public_ip = false
  cloudinit = "${data.ct_config.agent.rendered}"
}
