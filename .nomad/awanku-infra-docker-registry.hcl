job "awanku-infra-docker-registry" {
    datacenters = ["dc1"]
    group "docker-registry" {
        ephemeral_disk {
            migrate = true
            sticky  = true
            size    = "1000"
        }
        task "docker-registry" {
            driver = "docker"
            config {
                image = "registry:2"
                port_map {
                    http = 5000
                }
            }
            env {
                REGISTRY_STORAGE_FILESYSTEM_ROOTDIRECTORY = "/alloc/data/registry"
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
                    "traefik.http.routers.awanku-infra-docker-registry.rule=Host(`docker.awanku.id`)",
                    "traefik.http.routers.awanku-infra-docker-registry.entrypoints=https",
                    "traefik.http.routers.awanku-infra-docker-registry.tls=true",
                    "traefik.http.routers.awanku-infra-docker-registry.tls.options=default",
                    "traefik.http.routers.awanku-infra-docker-registry.middlewares=awankuInfraBasicAuth@consul",
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
