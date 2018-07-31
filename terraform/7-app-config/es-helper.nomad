job "elasticsearch" {
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

  group "proxy" {
    vault {
      policies      = ["nomad-es-helper"]
      change_mode   = "signal"
      change_signal = "SIGUSR1"
      env           = false
    }

    task "proxy" {
      driver = "docker"

      env {
        HTTPS_PROXY = "http.proxy.discovery.par1.vx-labs.net:3128"
        NO_PROXY    = "172.17.0.1:8200"
        VAULT_ADDR  = "http://172.17.0.1:8200"
      }

      config {
        port_map = {
          elasticsearch = 9200
        }

        force_pull = true
        image      = "quay.io/vxlabs/es-vault-proxy:latest"
      }

      resources {
        cpu    = 20
        memory = 32

        network {
          mbits = 10

          port "elasticsearch" {}
        }
      }

      service {
        name = "ElasticsearchHelper"
        port = "elasticsearch"
        tags = ["leader"]

        check {
          type     = "http"
          path     = "/"
          port     = "elasticsearch"
          interval = "30s"
          timeout  = "2s"
        }
      }
    }
  }
}
