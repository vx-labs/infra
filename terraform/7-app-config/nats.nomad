job "NATS" {
  datacenters = ["dc1"]
  type        = "service"

  update {
    max_parallel     = 1
    min_healthy_time = "10s"
    healthy_deadline = "1m"
    health_check     = "checks"
    auto_revert      = true
    canary           = 0
  }

  group "nats" {
    count = 1

    task "nats" {
      driver = "docker"

      env {
        DD_APM_ENABLED = "true"
      }

      config {
        args = [
          "-cid",
          "events",
          "-cluster",
          "nats://0.0.0.0:6222",
        ]

        port_map = {
          clients    = 4222
          routes     = 6222
          management = 8222
        }

        image = "nats-streaming:0.10.2"
      }

      resources {
        cpu    = 100
        memory = 128

        network {
          mbits = 10
        }
      }
    }
  }
}
