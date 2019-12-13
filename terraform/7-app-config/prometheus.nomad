job "prometheus" {
  datacenters = ["dc1"]
  type        = "service"

  group "monitoring" {
    count = 1

    restart {
      attempts = 2
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

    ephemeral_disk {
      size = 300
    }

    task "prometheus" {
      template {
        change_mode = "noop"
        destination = "local/prometheus.yml"

        data = <<EOH
---
global:
  scrape_interval:     5s
  evaluation_interval: 5s

scrape_configs:

  - job_name: 'mqtt_metrics'

    consul_sd_configs:
    - server: '{{ env "NOMAD_IP_prometheus_ui" }}:8500'
      services: ['mqtt-metrics']
    scrape_interval: 30s
    metrics_path: /metrics
    params:
      format: ['prometheus']
  - job_name: 'nomad_metrics'

    consul_sd_configs:
    - server: '{{ env "NOMAD_IP_prometheus_ui" }}:8500'
      services: ['nomad-client', 'nomad']
    scrape_interval: 30s
    metrics_path: /v1/metrics
    params:
      format: ['prometheus']
EOH
      }

      driver = "docker"

      config {
        image = "prom/prometheus:v2.10.0"

        volumes = [
          "local/prometheus.yml:/etc/prometheus/prometheus.yml",
          "local/:/prometheus/",
        ]

        port_map {
          prometheus_ui = 9090
        }
      }

      resources {
        cpu    = 200
        memory = 512

        network {
          mbits = 10
          port  "prometheus_ui"{}
        }
      }

      service {
        name = "prometheus"
        tags = ["urlprefix-prometheus.cloud.vx-labs.net/"]
        port = "prometheus_ui"

        check {
          name     = "prometheus_ui port alive"
          type     = "http"
          path     = "/-/healthy"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
