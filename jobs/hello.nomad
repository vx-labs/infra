job "hello" {
  datacenters = ["dc1"]
  type = "service"
  update {
    max_parallel = 1
    min_healthy_time = "10s"
    healthy_deadline = "3m"
    auto_revert = false
    canary = 0
  }
  group "front" {
    count = 1
    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }
    ephemeral_disk {
      size = 300
    }
    task "web" {
      driver = "docker"
      config {
        image = "emilevauge/whoami"
        port_map {
          db = 80
        }
      }
      resources {
        cpu    = 500 # 500 MHz
        memory = 128 # 256MB
        network {
          mbits = 10
          port "db" {}
        }
      }
      service {
        name = "hello-world"
        tags = ["global", "urlprefix-51.15.231.157:80/"]
        port = "db"
        check {
          name     = "alive"
          type     = "tcp"
          interval = "10s"
          timeout  = "2s"
        }
      }
    }
  }
}
