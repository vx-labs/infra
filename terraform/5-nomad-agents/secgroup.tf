resource "scaleway_instance_security_group" "nomad_agent" {
  inbound_default_policy = "drop"
  name                   = "nomad-agents"
  description            = "Nomad agents"

  inbound_rule {
    action   = "accept"
    protocol = "ANY"
    ip_range = "10.0.0.0/8"
  }
}
