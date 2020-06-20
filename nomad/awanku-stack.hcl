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
                    "traefik.http.routers.docker-registry.rule=Host(`docker.awanku.id`)",
                    "traefik.http.routers.docker-registry.entrypoints=https",
                    "traefik.http.routers.docker-registry.tls=true",
                    "traefik.http.routers.docker-registry.tls.certresolver=gratisan",
                    "traefik.http.routers.docker-registry.middlewares=docker-registry-basic-auth",
                    "traefik.http.middlewares.docker-registry-basic-auth.basicauth.users=awanku:$apr1$jd5pi2l4$B7PpKD4vEPo6izga3Z3GB1",
                    "traefik.http.middlewares.docker-registry-basic-auth.basicauth.realm=Awanku Docker Registry",
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
