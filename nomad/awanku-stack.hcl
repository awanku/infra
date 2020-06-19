job "awanku-infra" {
    datacenters = ["dc1"]
    constraint {
        attribute = "${attr.unique.hostname}"
        value = "s1-2-sgp1-1"
    }
    group "docker-registry" {
        task "docker-registry" {
            driver = "docker"
            config {
                image = "registry:2"
                port_map {
                    http = 5000
                }
                volumes = [
                    "/awanku/registry/storage:/var/lib/registry"
                ]
            }
            service {
                name = "docker-registry"
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
                    "traefik.http.routers.docker-registry.rule=Host(`docker.awanku.xyz`)",
                    "traefik.http.routers.docker-registry.entrypoints=http,https",
                    "traefik.http.routers.docker-registry.tls=true",
                    "traefik.http.routers.docker-registry.tls.certresolver=gratisan"
                ]
            }
            resources {
                network {
                    port "http" {}
                }
            }
        }
    }
}
