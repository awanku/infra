job "awanku" {
    datacenters = ["dc1"]
    constraint {
        attribute = "${meta.for_systems}"
        value     = true
    }
    group "docker-registry" {
        task "docker-registry" {
            driver = "docker"
            config {
                image = "registry:2"
                port_map {
                    http = 5000
                }
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
            }
            resources {
                network {
                    port "http" {}
                }
            }
        }
    }
}
