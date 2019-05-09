provider "vault" {}

module "nats-1" {
  source           = "../modules/instance"
  image            = "${element(var.nats_images, 0)}"
  secgroup         = "${scaleway_security_group.nats_server.id}"
  hostname         = "nats-1"
  region           = "${var.region}"
  domain           = "${var.cloudflare_domain}"
  cloudinit        = "${file("config.yaml")}"
  discovery_record = "servers.nats"
  user_data_count  = 2
}
resource "scaleway_user_data" "nats-id" {
  server = "${module.nats-1.instance_id}"
  key    = "NATS_ID"
  value  = "1"
}

resource "scaleway_user_data" "server-1-args" {
  server = "${module.nats-1.instance_id}"
  key    = "NATS_ROUTES"
  value  = "nats://${module.nats-2.instance_private_ip}:5222,nats://${module.nats-3.instance_private_ip}:5222"
}

module "nats-2" {
  source           = "../modules/instance"
  image            = "${element(var.nats_images, 1)}"
  secgroup         = "${scaleway_security_group.nats_server.id}"
  hostname         = "nats-2"
  region           = "${var.region}"
  domain           = "${var.cloudflare_domain}"
  cloudinit        = "${file("config.yaml")}"
  discovery_record = "servers.nats"
  user_data_count  = 2
}
resource "scaleway_user_data" "nats-2-id" {
  server = "${module.nats-2.instance_id}"
  key    = "NATS_ID"
  value  = "2"
}

resource "scaleway_user_data" "server-2-args" {
  server = "${module.nats-2.instance_id}"
  key    = "NATS_ROUTES"
  value  = "nats://${module.nats-1.instance_private_ip}:5222,nats://${module.nats-3.instance_private_ip}:5222"
}

module "nats-3" {
  source           = "../modules/instance"
  image            = "${element(var.nats_images, 2)}"
  secgroup         = "${scaleway_security_group.nats_server.id}"
  hostname         = "nats-3"
  region           = "${var.region}"
  domain           = "${var.cloudflare_domain}"
  cloudinit        = "${file("config.yaml")}"
  discovery_record = "servers.nats"
  user_data_count  = 2
}
resource "scaleway_user_data" "nats-3-id" {
  server = "${module.nats-3.instance_id}"
  key    = "NATS_ID"
  value  = "3"
}

resource "scaleway_user_data" "server-3-args" {
  server = "${module.nats-3.instance_id}"
  key    = "NATS_ROUTES"
  value  = "nats://${module.nats-1.instance_private_ip}:5222,nats://${module.nats-2.instance_private_ip}:5222"
}

resource "scaleway_security_group" "nats_server" {
  name        = "nats"
  description = "NATS servers"
}


output "streaming-url" {
  value = "nats-streaming://servers.nats.discovery.par1.${var.cloudflare_domain}:4222"
}
