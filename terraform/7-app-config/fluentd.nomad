job "logzio" {
  datacenters = ["dc1"]
  type        = "system"

  group "logzio" {
    restart {
      attempts = 2
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

    ephemeral_disk {
      size = 300
    }

    task "fluentd" {
      env {
        http_proxy  = "http://http.proxy.discovery.par1.vx-labs.net:3128"
        https_proxy = "http://http.proxy.discovery.par1.vx-labs.net:3128"
      }

      vault {
        policies = ["nomad-logzio-shipper"]
      }

      template {
        change_mode = "noop"
        destination = "local/fluentd.conf"

        data = <<EOH
<source>
  @type forward
</source>
<filter **>
  @type parser
  key_name log
  format json
  reserve_data false
</filter>
<match **>
  @type logzio_buffered
{{ with secret "secret/data/vx/logzio" }}
  endpoint_url "https://listener.logz.io:8071?token={{ .Data.token }}&type=mqtt"
{{ end }}
  output_include_time true
  output_include_tags true
  output_tags_fieldname @log_name
  buffer_type    file
  buffer_path    /tmp/fluentd.buffer
  proxy_uri http://http.proxy.discovery.fr-par.vx-labs.net:3128
  flush_interval 10s
  buffer_chunk_limit 1m   # Logz.io has bulk limit of 10M. We #recommend set this to 1M, to avoid oversized bulks
</match>

EOH
      }

      driver = "docker"

      config {
        network_mode = "host"
        image        = "jbonachera/fluentd-logzio:latest"

        volumes = [
          "local/fluentd.conf:/home/fluent/fluent.conf",
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
