variable "region" {}
variable "domain" {}
variable "image" {}
variable "hostname" {}
variable "secgroup" {}

variable "user_data_count" {
  default = 0
}

variable "cloudinit" {
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
  name         = "${var.image}"
}

data "ct_config" "instance" {
  content      = "${var.cloudinit}"
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

resource "scaleway_server" "instance" {
  name                = "${var.hostname}"
  image               = "${data.scaleway_image.master.id}"
  dynamic_ip_required = "${var.public_ip}"
  enable_ipv6         = false
  type                = "${var.type}"
  boot_type           = "local"
  security_group      = "${var.secgroup}"
  cloudinit           = "${data.ct_config.instance.rendered}"
}

resource "scaleway_user_data" "http_proxy" {
  server = "${scaleway_server.instance.id}"
  key    = "http_proxy"
  value  = "http://http.proxy.discovery.${var.region}.${var.domain}:3128"
}

resource "scaleway_user_data" "https_proxy" {
  server = "${scaleway_server.instance.id}"
  key    = "https_proxy"
  value  = "http://http.proxy.discovery.${var.region}.${var.domain}:3128"
}

resource "scaleway_user_data" "ud_count" {
  server = "${scaleway_server.instance.id}"
  key    = "COUNT"
  value  = "${format("%d", 3 + var.user_data_count)}"
}

resource "cloudflare_record" "discovery_record" {
  domain = "${var.domain}"
  name   = "${var.discovery_record}.discovery.${var.region}"
  value  = "${scaleway_server.instance.private_ip}"
  type   = "A"
  ttl    = 1
}
resource "cloudflare_record" "hostname_record" {
  domain = "${var.domain}"
  name   = "${var.hostname}.instance.discovery.${var.region}"
  value  = "${scaleway_server.instance.private_ip}"
  type   = "A"
  ttl    = 1
}

output "instance_id" {
  value = "${scaleway_server.instance.id}"
}

output "instance_private_ip" {
  value = "${scaleway_server.instance.private_ip}"
}

output "instance_public_ip" {
  value = "${scaleway_server.instance.public_ip}"
}
