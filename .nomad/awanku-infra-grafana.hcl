job "awanku-infra-grafana" {
    datacenters = ["dc1"]
    group "grafana" {
        ephemeral_disk {
            migrate = true
            size    = "300"
            sticky  = true
        }
        task "grafana" {
            driver = "exec"
            config {
                command = "${NOMAD_TASK_DIR}/run.sh"
            }
            artifact {
                source = "https://dl.grafana.com/oss/release/grafana-7.0.3.linux-amd64.tar.gz"
            }
            template {
                data = <<BASH
#!/usr/bin/env bash
set -x
mkdir -p ${NOMAD_ALLOC_DIR}/data/grafana
cp -a ${NOMAD_TASK_DIR}/grafana-7.0.3 ${NOMAD_ALLOC_DIR}/grafana
cd ${NOMAD_ALLOC_DIR}/grafana
bin/grafana-server -config ${NOMAD_TASK_DIR}/config.ini
BASH
                destination = "${NOMAD_TASK_DIR}/run.sh"
                perms = "775"
            }
            template {
                data = <<EOF
[paths]
data = ${NOMAD_ALLOC_DIR}/data/grafana

[server]
protocol = http
http_addr = ${NOMAD_IP_http}
http_port = ${NOMAD_PORT_http}

[security]
admin_user = awanku
admin_password = rahasia
EOF
                destination = "${NOMAD_TASK_DIR}/config.ini"
                perms = "664"
            }
            resources {
                network {
                    port "http" {}
                }
            }
            service {
                name = "grafana"
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
                    "traefik.http.routers.awanku-infra-grafana.rule=Host(`grafana.internal.awanku.id`)",
                    "traefik.http.routers.awanku-infra-grafana.entrypoints=internal",
                    "traefik.http.routers.awanku-infra-grafana.tls=true",
                    "traefik.http.routers.awanku-infra-grafana.tls.options=default",
                ]
            }
        }
    }
}
