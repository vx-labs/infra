job "jaeger-agent" {
  datacenters = ["dc1"]
  type        = "system"

  update {
    max_parallel     = 1
    min_healthy_time = "10s"
    healthy_deadline = "1m"
    health_check     = "checks"
    auto_revert      = true
    canary           = 0
  }

  group "agent" {
    task "agent" {
      driver = "docker"

      config {
        command = "--collector.host-port=${NOMAD_IP_jaeger_compact}:14267"

        port_map = {
          jaeger_compact = 6831
          jaeger_binary  = 6832
          jaeger_config  = 5778
        }

        image = "jaegertracing/jaeger-agent"
      }

      resources {
        cpu    = 20
        memory = 32

        network {
          mbits = 10

          port "jaeger_compact" {
            static = "6831"
          }
        }
      }
    }
  }
}
