job "awanku" {
    datacenters = ["dc1"]
    group "echo" {
        count = 5
        task "echo" {
            driver = "docker"
            config {
                image = "jmalloc/echo-server"
                port_map {
                    http = 8080
                }
            }
            service {
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
