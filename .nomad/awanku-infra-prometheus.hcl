job "awanku-infra-prometheus" {
    datacenters = ["dc1"]
    group "prometheus" {
        ephemeral_disk {
            migrate = true
            sticky  = true
            size    = "500"
        }
        task "prometheus" {
            driver = "exec"
            artifact {
                source = "https://github.com/prometheus/prometheus/releases/download/v2.19.1/prometheus-2.19.1.linux-amd64.tar.gz"
            }
            config {
                command = "local/prometheus-2.19.1.linux-amd64/prometheus"
                args = [
                    "--config.file=${NOMAD_TASK_DIR}/prometheus.yml",
                    "--web.listen-address=${NOMAD_IP_http}:${NOMAD_PORT_http}",
                    "--storage.tsdb.path=${NOMAD_ALLOC_DIR}/data/prometheus",
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
                destination = "${NOMAD_TASK_DIR}/prometheus.yml"
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
                tags = [
                    "traefik.enable=true",
                    "traefik.http.routers.awanku-infra-prometheus.rule=Host(`prometheus.internal.awanku.id`)",
                    "traefik.http.routers.awanku-infra-prometheus.entrypoints=internal",
                    "traefik.http.routers.awanku-infra-prometheus.tls=true",
                    "traefik.http.routers.awanku-infra-prometheus.tls.options=default",
                ]
            }
        }
    }
}
