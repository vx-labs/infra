provider "vault" {}

module "server-1" {
  source           = "../modules/instance"
  image            = "${element(var.master_images, 0)}"
  secgroup         = "${scaleway_security_group.nomad_server.id}"
  hostname         = "nomad-server-1"
  region           = "${var.region}"
  domain           = "${var.cloudflare_domain}"
  cloudinit        = "${file("config.yaml")}"
  discovery_record = "servers.nomad"
  vault_role       = "nomad-role"
  vault_token_role = "nomad-cluster"
  user_data_count  = 1
}

resource "scaleway_user_data" "cluster_size_1" {
  server = "${module.server-1.instance_id}"
  key    = "CLUSTER_SIZE"
  value  = "${length(var.master_images)}"
}

module "server-2" {
  source           = "../modules/instance"
  image            = "${element(var.master_images, 1)}"
  secgroup         = "${scaleway_security_group.nomad_server.id}"
  hostname         = "nomad-server-2"
  region           = "${var.region}"
  domain           = "${var.cloudflare_domain}"
  cloudinit        = "${file("config.yaml")}"
  discovery_record = "servers.nomad"
  vault_role       = "nomad-role"
  vault_token_role = "nomad-cluster"
  user_data_count  = 1
}

resource "scaleway_user_data" "cluster_size_2" {
  server = "${module.server-2.instance_id}"
  key    = "CLUSTER_SIZE"
  value  = "${length(var.master_images)}"
}

module "server-3" {
  source           = "../modules/instance"
  image            = "${element(var.master_images, 2)}"
  secgroup         = "${scaleway_security_group.nomad_server.id}"
  hostname         = "nomad-server-3"
  region           = "${var.region}"
  domain           = "${var.cloudflare_domain}"
  cloudinit        = "${file("config.yaml")}"
  discovery_record = "servers.nomad"
  vault_role       = "nomad-role"
  vault_token_role = "nomad-cluster"
  user_data_count  = 1
}

resource "scaleway_user_data" "cluster_size_3" {
  server = "${module.server-3.instance_id}"
  key    = "CLUSTER_SIZE"
  value  = "${length(var.master_images)}"
}
resource "scaleway_security_group" "nomad_server" {
  name        = "nomad-server"
  description = "Nomad servers (masters)"
}
