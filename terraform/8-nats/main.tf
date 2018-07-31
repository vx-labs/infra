provider "vault" {}

module "server-1" {
  source       = "./modules/nats"
  image        = "${element(var.nats_images, 0)}"
  secgroup     = "${scaleway_security_group.nats_server.id}"
  index        = "1"
  expect_count = "${length(var.nats_images)}"
  region       = "${var.region}"
  domain       = "${var.cloudflare_domain}"
  public_ip    = false
}

module "server-2" {
  source       = "./modules/nats"
  image        = "${element(var.nats_images, 1)}"
  secgroup     = "${scaleway_security_group.nats_server.id}"
  index        = "2"
  expect_count = "${length(var.nats_images)}"
  region       = "${var.region}"
  domain       = "${var.cloudflare_domain}"
  public_ip    = false
}

module "server-3" {
  source       = "./modules/nats"
  image        = "${element(var.nats_images, 2)}"
  secgroup     = "${scaleway_security_group.nats_server.id}"
  index        = "3"
  expect_count = "${length(var.nats_images)}"
  region       = "${var.region}"
  domain       = "${var.cloudflare_domain}"
  public_ip    = false
}

resource "scaleway_security_group" "nats_server" {
  name        = "nats"
  description = "NATS servers"
}

resource "scaleway_user_data" "server-1-args" {
  server = "${module.server-1.server_id}"
  key    = "NATS_ROUTES"
  value  = "nats://${module.server-2.server_private_ip}:5222,nats://${module.server-3.server_private_ip}:5222"
}

resource "scaleway_user_data" "server-2-args" {
  server = "${module.server-2.server_id}"
  key    = "NATS_ROUTES"
  value  = "nats://${module.server-1.server_private_ip}:5222,nats://${module.server-3.server_private_ip}:5222"
}

resource "scaleway_user_data" "server-3-args" {
  server = "${module.server-3.server_id}"
  key    = "NATS_ROUTES"
  value  = "nats://${module.server-2.server_private_ip}:5222,nats://${module.server-1.server_private_ip}:5222"
}
