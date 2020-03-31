job "netadata" {
  datacenters = ["dc1"]
  type        = "system"

  group "netdata" {
    restart {
      attempts = 2
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

    ephemeral_disk {
      size = 300
    }

    task "netdata" {
      env {
        http_proxy  = "http://http.proxy.discovery.fr-par.vx-labs.net:3128"
        https_proxy = "http://http.proxy.discovery.fr-par.vx-labs.net:3128"
      }

      driver = "docker"

      config {
        network_mode = "host"
        image        = "netdata/netdata"

        cap_add = []

        volumes = [
          "/proc:/host/proc:ro",
          "/sys:/host/sys:ro",
          "/var/run/docker.sock:/var/run/docker.sock:ro",
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
