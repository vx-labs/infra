job "ci-builder" {
  datacenters = ["dc1"]
  type        = "batch"

  parameterized {
    payload       = "forbidden"
    meta_required = ["repository_url", "ref"]
  }

  group "ci-builder" {
    restart {
      attempts = 0
      mode     = "fail"
    }

    vault {
      policies    = ["nomad-ci-builder"]
      change_mode = "noop"
      env         = true
    }

    task "ci-builder" {
      driver = "docker"

      env {
        HTTP_PROXY  = "http.proxy.discovery.par1.vx-labs.net:3128"
        HTTPS_PROXY = "http.proxy.discovery.par1.vx-labs.net:3128"
        NO_PROXY    = "172.17.0.1:8200"
        VAULT_ADDR  = "http://172.17.0.1:8200"
      }

      config {
        force_pull = true
        image      = "quay.io/vxlabs/go-dep-builder"
        command    = "${NOMAD_META_repository_url}"

        volumes = [
          "/var/run/docker.sock:/var/run/docker.sock:ro",
        ]
      }

      dispatch_payload {
        file = "config.json"
      }

      resources {
        cpu    = 500
        memory = 256

        network {
          mbits = 10
        }
      }
    }
  }
}
