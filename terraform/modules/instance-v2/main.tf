variable "region" {}
variable "domain" {}
variable "image" {}
variable "hostname" {}
variable "secgroup" {}
variable "user_data" {
  default = []
  type = list(object({
    key   = string
    value = string
  }))
}
variable "cloud_init" {
  default = ""
}

variable "type" {
  default = "START1-XS"
}

variable "public_ip" {
  default = false
}
variable "discovery_record" {}

data "scaleway_image" "master" {
  architecture = "x86_64"
  name         = var.image
}

data "ct_config" "instance" {
  content      = var.cloud_init
  platform     = "custom"
  pretty_print = false

  snippets = [
    <<EOF
storage:
  files:
    - filesystem: "root"
      path:       "/etc/hostname"
      mode:       0644
      contents:
        inline: ${var.hostname}
EOF
    ,
  ]
}

resource "scaleway_instance_server" "instance" {
  name              = var.hostname
  image             = data.scaleway_image.master.id
  enable_dynamic_ip = var.public_ip
  enable_ipv6       = false
  type              = var.type
  security_group_id = var.secgroup
  cloud_init        = data.ct_config.instance.rendered
  root_volume {
    delete_on_termination = true
  }
  user_data {
    key   = "http_proxy"
    value = "http://http.proxy.discovery.${var.region}.${var.domain}:3128"
  }
  user_data {
    key   = "https_proxy"
    value = "http://http.proxy.discovery.${var.region}.${var.domain}:3128"
  }
  user_data {
    key   = "COUNT"
    value = format("%d", 3 + length(var.user_data))
  }
  dynamic "user_data" {
    for_each = var.user_data
    content {
      key   = user_data.value.key
      value = user_data.value.value
    }
  }

}

data "cloudflare_zones" "main_zone" {
  filter {
    name   = var.domain
    status = "active"
    paused = false
  }
}

resource "cloudflare_record" "discovery_record" {
  zone_id = data.cloudflare_zones.main_zone.zones[0].id
  name    = "${var.discovery_record}.discovery.${var.region}"
  value   = scaleway_instance_server.instance.private_ip
  type    = "A"
  ttl     = 1
}
resource "cloudflare_record" "hostname_record" {
  zone_id = data.cloudflare_zones.main_zone.zones[0].id
  name    = "${var.hostname}.instance.discovery.${var.region}"
  value   = "${split("/", scaleway_instance_server.instance.id)[1]}.priv.cloud.scaleway.com"
  type    = "CNAME"
  ttl     = 1
}

output "instance_id" {
  value = scaleway_instance_server.instance.id
}

output "instance_private_ip" {
  value = scaleway_instance_server.instance.private_ip
}

output "instance_public_ip" {
  value = scaleway_instance_server.instance.public_ip
}
