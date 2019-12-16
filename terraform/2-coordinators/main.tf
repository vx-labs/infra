resource "scaleway_instance_placement_group" "availability_group" {
  name        = "coordinators"
  policy_mode = "enforced"
}

module "coordinator-1" {
  source             = "../modules/instance-v2"
  image              = element(var.coordinator_images, 0)
  secgroup           = scaleway_security_group.coordinator.id
  hostname           = "coordinator-1"
  region             = var.region
  domain             = var.cloudflare_domain
  cloud_init         = file("config.yaml")
  placement_group_id = scaleway_instance_placement_group.availability_group.id
  discovery_record   = "servers.consul"
  user_data = [{
    key   = "CONSUL_JOIN_LIST"
    value = "servers.consul.discovery.${var.region}.${var.cloudflare_domain}"
    }, {
    key   = "CONSUL_CLUSTER_SIZE"
    value = length(var.coordinator_images)
  }]
}

module "coordinator-2" {
  source             = "../modules/instance-v2"
  image              = element(var.coordinator_images, 1)
  secgroup           = scaleway_security_group.coordinator.id
  hostname           = "coordinator-2"
  region             = var.region
  domain             = var.cloudflare_domain
  cloud_init         = file("config.yaml")
  placement_group_id = scaleway_instance_placement_group.availability_group.id
  discovery_record   = "servers.consul"
  user_data = [{
    key   = "CONSUL_JOIN_LIST"
    value = "servers.consul.discovery.${var.region}.${var.cloudflare_domain}"
    }, {
    key   = "CONSUL_CLUSTER_SIZE"
    value = length(var.coordinator_images)
  }]
}

module "coordinator-3" {
  source             = "../modules/instance-v2"
  image              = element(var.coordinator_images, 2)
  secgroup           = scaleway_security_group.coordinator.id
  hostname           = "coordinator-3"
  region             = var.region
  domain             = var.cloudflare_domain
  cloud_init         = file("config.yaml")
  placement_group_id = scaleway_instance_placement_group.availability_group.id
  discovery_record   = "servers.consul"
  user_data = [{
    key   = "CONSUL_JOIN_LIST"
    value = "servers.consul.discovery.${var.region}.${var.cloudflare_domain}"
    }, {
    key   = "CONSUL_CLUSTER_SIZE"
    value = length(var.coordinator_images)
  }]
}

resource "scaleway_security_group" "coordinator" {
  name        = "coordinators"
  description = "Coordinators"
}
