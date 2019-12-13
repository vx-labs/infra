job "grafana" {
  datacenters = ["dc1"]
  type        = "service"

  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

  update {
    stagger      = "30s"
    max_parallel = 1
  }

  group "grafana" {
    vault {
      policies    = ["nomad-grafana"]
      change_mode = "restart"
      env         = false
    }

    restart {
      attempts = 10
      interval = "5m"
      delay    = "10s"
      mode     = "delay"
    }

    task "grafana" {
      driver = "docker"

      config {
        image = "grafana/grafana"
        args  = ["-config", "${NOMAD_TASK_DIR}/conf/custom.ini"]
      }

      env {
        GF_LOG_LEVEL          = "INFO"
        GF_LOG_MODE           = "console"
        GF_SERVER_HTTP_PORT   = "${NOMAD_PORT_http}"
        GF_PATHS_PROVISIONING = "${NOMAD_TASK_DIR}/provisioning"
      }

      template {
        destination = "local/proxy.conf"
        env         = true

        data = <<EOH
{{with secret "secret/data/vx/mqtt"}}
http_proxy="{{.Data.http_proxy}}"
https_proxy="{{.Data.http_proxy}}"
no_proxy="10.0.0.0/8,172.16.0.0/12"
{{end}}
        EOH
      }

      template {
        change_mode = "restart"
        destination = "local/conf/custom.ini"

        data = <<EOH
[server]
root_url = http://grafana.cloud.vx-labs.net
[security]
admin_user = julien@bonachera.fr
disable_gravatar = true
[auth.basic]
enabled = false
[auth]
disable_login_form = true
oauth_auto_login = true
[auth.google]
enabled = true
client_id = 77887817414-c8lnoc8v1beseji3qgfndrdhsgo1tgj5.apps.googleusercontent.com
client_secret = ZJ_dnCl-lTJMWe8dDnJzvnw_
scopes = https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/userinfo.email
auth_url = https://accounts.google.com/o/oauth2/auth
token_url = https://accounts.google.com/o/oauth2/token
allowed_domains = bonachera.fr
allow_sign_up = true

EOH
      }

      template {
        change_mode = "restart"
        destination = "local/provisioning/datasources/prometheus.yaml"

        data = <<EOH
---
apiVersion: 1

datasources:
  - name: Prometheus
    type: prometheus
    access: proxy
    url: http://prometheus.cloud.vx-labs.net/

EOH
      }

      template {
        change_mode = "restart"
        destination = "local/provisioning/dashboards/nomad.json"

        data = <<EOH
{{with secret "secret/data/vx/grafana" }}
{{ base64Decode .Data.nomad }}
{{end}}
EOH
      }

      resources {
        cpu    = 1000
        memory = 256

        network {
          mbits = 10
          port  "http"{}
        }
      }

      service {
        name = "grafana"
        port = "http"
        tags = ["urlprefix-grafana.cloud.vx-labs.net/"]

        check {
          name     = "Grafana HTTP"
          type     = "http"
          path     = "/api/health"
          interval = "5s"
          timeout  = "2s"

          check_restart {
            limit           = 2
            grace           = "60s"
            ignore_warnings = false
          }
        }
      }
    }
  }
}
