resource "cloudflare_record" "nomad_agent" {
  count  = "${var.agent_count}"
  domain = "${var.cloudflare_domain}"
  name   = "agent.nomad.${var.region}"
  value  = "${element(scaleway_server.nomad-agent.*.public_ip, count.index)}"
  type   = "A"
  ttl    = 1
}

