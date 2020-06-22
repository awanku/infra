job "awanku-infra-telegraf" {
    datacenters = ["dc1"]
    type = "system"
    group "telegraf" {
        task "telegraf" {
            driver = "exec"
            artifact {
                source = "https://dl.influxdata.com/telegraf/releases/telegraf-1.14.4_linux_amd64.tar.gz"
            }
            config {
                command = "local/telegraf/usr/bin/telegraf"
                args = [
                    "--config", "local/telegraf.conf",
                ]
            }
            template {
                data = <<EOH
[agent]
  interval = "10s"

[[inputs.mem]]

[[inputs.cpu]]

[[outputs.prometheus_client]]
  listen = "{{ env "NOMAD_IP_metrics" }}:{{ env "NOMAD_PORT_metrics" }}"
  metric_version = 2
EOH
                destination = "local/telegraf.conf"
            }
            service {
                name = "telegraf-metrics"
                port = "metrics"
                check {
                    type = "http"
                    path = "/metrics"
                    port = "metrics"
                    interval = "10s"
                    timeout = "1s"
                }
            }
            resources {
                network {
                    port "metrics" {}
                }
            }
        }
    }
}
