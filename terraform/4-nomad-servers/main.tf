provider "vault" {}

module "server-1" {
  source       = "./modules/nomad-master"
  image        = "${element(var.master_images, 0)}"
  secgroup     = "${scaleway_security_group.nomad_server.id}"
  index        = "1"
  expect_count = "${length(var.master_images)}"
  region       = "${var.region}"
  domain       = "${var.cloudflare_domain}"
  public_ip    = false
}

module "server-2" {
  source       = "./modules/nomad-master"
  image        = "${element(var.master_images, 1)}"
  secgroup     = "${scaleway_security_group.nomad_server.id}"
  index        = "2"
  expect_count = "${length(var.master_images)}"
  region       = "${var.region}"
  domain       = "${var.cloudflare_domain}"
  public_ip    = false
}

module "server-3" {
  source       = "./modules/nomad-master"
  image        = "${element(var.master_images, 2)}"
  secgroup     = "${scaleway_security_group.nomad_server.id}"
  index        = "3"
  expect_count = "${length(var.master_images)}"
  region       = "${var.region}"
  domain       = "${var.cloudflare_domain}"
  public_ip    = false
}

resource "scaleway_security_group" "nomad_server" {
  name        = "nomad-server"
  description = "Nomad servers (masters)"
}
