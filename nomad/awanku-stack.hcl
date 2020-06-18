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

                    check_restart {
                        limit = 3
                        grace = "60s"
                    }
                }
            }
            resources {
                network {
                    port "http" {}
                }
            }
        }
    }
    group "postgresql" {
        task "postgresql" {
            driver = "docker"
            config {
                image = "postgres:12"
                port_map {
                    pg = 5432
                }
                volumes = [
                    "/awanku/maindb/pgdata:/var/lib/postgresql/data"
                ]
            }
            service {
                name = "awanku-db-main"
                port = "pg"

                check {
                    type     = "tcp"
                    port     = "pg"
                    interval = "10s"
                    timeout  = "1s"

                    check_restart {
                        limit = 3
                        grace = "30s"
                    }
                }
            }
            env {
                POSTGRES_USER = "awanku"
                POSTGRES_PASSWORD = "rahasia"
                POSTGRES_DB = "awanku"
            }
            resources {
                network {
                    port "pg" {}
                }
            }
        }
    }
}
