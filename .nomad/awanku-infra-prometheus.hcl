job "awanku-infra-prometheus" {
    datacenters = ["dc1"]
    group "prometheus" {
        ephemeral_disk {
            migrate = true
            size    = "500"
            sticky  = true
        }
        task "prometheus" {
            driver = "exec"
            artifact {
                source = "https://github.com/prometheus/prometheus/releases/download/v2.19.1/prometheus-2.19.1.linux-amd64.tar.gz"
            }
            config {
                command = "local/prometheus-2.19.1.linux-amd64/prometheus"
                args = [
                    "--config.file=local/prometheus.yml",
                    "--web.listen-address=${NOMAD_IP_http}:${NOMAD_PORT_http}",
                    "--storage.tsdb.path=local/data",
                ]
            }
            template {
                data = <<EOH
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'consul'
    consul_sd_configs:
      - server: '{{ env "NOMAD_IP_http" }}:8500'
        services:
          - telegraf-metrics
EOH
                destination = "local/prometheus.yml"
            }
            resources {
                network {
                    port "http" {}
                }
            }
            service {
                name = "prometheus"
                port = "http"
                check {
                    type = "http"
                    path = "/"
                    port = "http"
                    interval = "10s"
                    timeout = "1s"
                }
            }
        }
    }
}
