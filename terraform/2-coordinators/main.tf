module "coordinator-1" {
  source       = "./modules/coordinator"
  image        = "${element(var.coordinator_images, 0)}"
  secgroup     = "${scaleway_security_group.coordinator.id}"
  index        = "1"
  expect_count = "${length(var.coordinator_images)}"
  region       = "${var.region}"
  domain       = "${var.cloudflare_domain}"
  public_ip    = false
  type         = "START1-XS"
}

resource "scaleway_user_data" "consul_join_list_1" {
  server = "${module.coordinator-1.server_id}"
  key    = "CONSUL_JOIN_LIST"
  value  = "${module.coordinator-1.private_ip}"
}

module "coordinator-2" {
  source       = "./modules/coordinator"
  image        = "${element(var.coordinator_images, 1)}"
  secgroup     = "${scaleway_security_group.coordinator.id}"
  index        = "2"
  expect_count = "${length(var.coordinator_images)}"
  region       = "${var.region}"
  domain       = "${var.cloudflare_domain}"
  public_ip    = false
  type         = "START1-XS"
}

resource "scaleway_user_data" "consul_join_list_2" {
  server = "${module.coordinator-2.server_id}"
  key    = "CONSUL_JOIN_LIST"
  value  = "${module.coordinator-1.private_ip}"
}

module "coordinator-3" {
  source       = "./modules/coordinator"
  image        = "${element(var.coordinator_images, 2)}"
  secgroup     = "${scaleway_security_group.coordinator.id}"
  index        = "3"
  expect_count = "${length(var.coordinator_images)}"
  region       = "${var.region}"
  domain       = "${var.cloudflare_domain}"
  public_ip    = false
  type         = "START1-XS"
}

resource "scaleway_user_data" "consul_join_list_3" {
  server = "${module.coordinator-3.server_id}"
  key    = "CONSUL_JOIN_LIST"
  value  = "${module.coordinator-1.private_ip}"
}

resource "scaleway_security_group" "coordinator" {
  name        = "coordinators"
  description = "Coordinators"
}
