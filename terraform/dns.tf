locals {
    ingress_ips = ["51.79.143.80", "51.79.142.232"]
    cname_domains = ["api", "console", "docker", "*.apps"]
}

data "google_dns_managed_zone" "awanku_id" {
  name = "awanku-id"
}

data "google_dns_managed_zone" "awanku_xyz" {
  name = "awanku-xyz"
}

resource "google_dns_record_set" "awanku_id" {
  name = data.google_dns_managed_zone.awanku_id.dns_name
  type = "A"
  ttl  = 300

  managed_zone = data.google_dns_managed_zone.awanku_id.name
  rrdatas = local.ingress_ips
}

resource "google_dns_record_set" "acme" {
  name = data.google_dns_managed_zone.awanku_id.dns_name
  type = "CAA"
  ttl  = 86400

  managed_zone = data.google_dns_managed_zone.awanku_id.name
  rrdatas = [
    "0 issue \"letsencrypt.org\"",
  ]
}

resource "google_dns_record_set" "cname_awanku_id" {
  for_each = toset(local.cname_domains)

  name = "${each.value}.${data.google_dns_managed_zone.awanku_id.dns_name}"
  type = "CNAME"
  ttl  = 300

  managed_zone = data.google_dns_managed_zone.awanku_id.name
  rrdatas = [
    google_dns_record_set.awanku_id.name,
  ]
}

resource "google_dns_record_set" "internal_awanku_id" {
  name = "*.internal.${data.google_dns_managed_zone.awanku_id.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = data.google_dns_managed_zone.awanku_id.name
  rrdatas = [
    "10.99.0.4",
    "10.99.0.193",
  ]
}
