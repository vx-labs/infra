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
  add_tag_prefix net
</source>
<match net.**>
  @type rewrite_tag_filter
  <rule>
    key log
    pattern .*
    tag json
  </rule>
</match>
<filter json>
  @type parser
  key_name log
  format json
  reserve_data false
  emit_invalid_record_to_error false
</filter>
<match **>
  @type stdout
</match>
<match json>
  @type logzio_buffered
{{ with secret "secret/data/vx/logzio" }}
  endpoint_url "https://listener.logz.io:8071?token={{ .Data.token }}&type=mqtt"
{{ end }}
  output_include_time true
  output_include_tags true
  http_idle_timeout 10
  <buffer>
      @type memory
      flush_thread_count 4
      flush_interval 3s
      chunk_limit_size 16m      # Logz.io bulk limit is decoupled from chunk_limit_size. Set whatever you want.
      queue_limit_length 4096
  </buffer>
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
