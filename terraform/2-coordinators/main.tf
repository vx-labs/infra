module "coordinator-1" {
  source           = "../modules/instance"
  image            = "${element(var.coordinator_images, 0)}"
  secgroup         = "${scaleway_security_group.coordinator.id}"
  hostname         = "coordinator-1"
  region           = "${var.region}"
  domain           = "${var.cloudflare_domain}"
  cloudinit        = "${file("config.yaml")}"
  discovery_record = "servers.consul"
  user_data_count  = 2
}

resource "scaleway_user_data" "consul_join_list_1" {
  server = "${module.coordinator-1.instance_id}"
  key    = "CONSUL_JOIN_LIST"
  value  = "servers.consul.discovery.${var.region}.${var.cloudflare_domain}"
}
resource "scaleway_user_data" "consul_cluster_size_1" {
  server = "${module.coordinator-1.instance_id}"
  key    = "CONSUL_CLUSTER_SIZE"
  value  = "${length(var.coordinator_images)}"
}

module "coordinator-2" {
  source           = "../modules/instance"
  image            = "${element(var.coordinator_images, 1)}"
  secgroup         = "${scaleway_security_group.coordinator.id}"
  hostname         = "coordinator-2"
  region           = "${var.region}"
  domain           = "${var.cloudflare_domain}"
  cloudinit        = "${file("config.yaml")}"
  discovery_record = "servers.consul"
  user_data_count  = 2
}
resource "scaleway_user_data" "consul_cluster_size_2" {
  server = "${module.coordinator-2.instance_id}"
  key    = "CONSUL_CLUSTER_SIZE"
  value  = "${length(var.coordinator_images)}"
}
resource "scaleway_user_data" "consul_join_list_2" {
  server = "${module.coordinator-2.instance_id}"
  key    = "CONSUL_JOIN_LIST"
  value  = "servers.consul.discovery.${var.region}.${var.cloudflare_domain}"
}

module "coordinator-3" {
  source           = "../modules/instance"
  image            = "${element(var.coordinator_images, 2)}"
  secgroup         = "${scaleway_security_group.coordinator.id}"
  hostname         = "coordinator-3"
  region           = "${var.region}"
  domain           = "${var.cloudflare_domain}"
  cloudinit        = "${file("config.yaml")}"
  discovery_record = "servers.consul"
  user_data_count  = 2
}
resource "scaleway_user_data" "consul_cluster_size_3" {
  server = "${module.coordinator-3.instance_id}"
  key    = "CONSUL_CLUSTER_SIZE"
  value  = "${length(var.coordinator_images)}"
}
resource "scaleway_user_data" "consul_join_list_3" {
  server = "${module.coordinator-3.instance_id}"
  key    = "CONSUL_JOIN_LIST"
  value  = "${module.coordinator-1.instance_private_ip}"
}

resource "scaleway_security_group" "coordinator" {
  name        = "coordinators"
  description = "Coordinators"
}
