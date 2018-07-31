job "jaeger-collector" {
  datacenters = ["dc1"]
  type        = "system"

  update {
    max_parallel     = 1
    min_healthy_time = "10s"
    healthy_deadline = "3m"
    health_check     = "checks"
    auto_revert      = true
    canary           = 0
  }

  group "collector" {
    task "collector" {
      driver = "docker"

      env {
        SPAN_STORAGE_TYPE = "elasticsearch"
      }

      config {
        command = "--es.server-urls=http://172.17.0.1:9200 --es.num-shards=1"

        port_map = {
          jaeger_collector = 14267
          jaeger_health    = 14269
        }

        image = "jaegertracing/jaeger-collector"
      }

      resources {
        cpu    = 20
        memory = 64

        network {
          mbits = 10

          port "jaeger_collector" {
            static = 14267
          }

          port "jaeger_health" {}
        }
      }

      service {
        name = "JaegerCollector"
        port = "jaeger_collector"
        tags = ["leader"]

        check {
          type     = "http"
          path     = "/"
          port     = "jaeger_health"
          interval = "30s"
          timeout  = "2s"
        }
      }
    }
  }
}
