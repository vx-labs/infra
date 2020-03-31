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

  - job_name: 'haproxy'
    static_configs:
      - targets: ['lb-1.instance.discovery.fr-par.vx-labs.net:8404']
  - job_name: 'wasp'
    consul_sd_configs:
    - server: '{{ env "NOMAD_IP_prometheus_ui" }}:8500'
      services: ['wasp']
      tags: ['prometheus']
    scrape_interval: 30s
    metrics_path: /metrics
    params:
      format: ['prometheus']
  - job_name: 'nomad_metrics'
    consul_sd_configs:
    - server: '{{ env "NOMAD_IP_prometheus_ui" }}:8500'
      services: ['nomad-client', 'nomad']
      tags: ['http']
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
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.prometheus.rule=host(`prometheus.cloud.vx-labs.net`)",
          "traefik.http.routers.prometheus.service=prometheus",
          "traefik.http.routers.prometheus.tls.certresolver=le",
          "traefik.http.routers.prometheus.tls=true",
          "traefik.http.routers.prometheus.entrypoints=https"
        ]
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
