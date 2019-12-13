job "datadog" {
  datacenters = ["dc1"]
  type        = "system"

  group "datadog" {
    restart {
      attempts = 2
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

    ephemeral_disk {
      size = 300
    }

    task "datadog" {
      env {
        http_proxy  = "http://http.proxy.discovery.par1.vx-labs.net:3128"
        https_proxy = "http://http.proxy.discovery.par1.vx-labs.net:3128"
      }

      vault {
        policies = ["nomad-datadog-shipper"]
      }

      template {
        change_mode = "restart"
        env         = true
        destination = "local/datadog.conf"

        data = <<EOH
DD_PROCESS_AGENT_ENABLED="true"
DD_API_KEY="{{with secret "secret/data/vx/datadog"}}{{.Data.api_token}}{{end}}"
EOH
      }

      driver = "docker"

      config {
        network_mode = "host"
        image        = "datadog/agent:latest"

        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock:ro",
          "/proc/:/host/proc/:ro",
          "/sys/fs/cgroup/:/host/sys/fs/cgroup:ro",
        ]
      }

      resources {
        cpu    = 200
        memory = 128

        network {
          mbits = 10
        }
      }
    }
  }
}
