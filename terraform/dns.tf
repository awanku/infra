locals {
    ingress_ips = ["51.79.142.59", "51.79.140.121", "51.79.141.163"]
    internal_ingress_ips = ["10.99.1.85", "10.99.2.245", "10.99.0.177"]
    cname_domains = ["api", "console", "docker", "*.apps"]
    staging_domain_cnames = ["api", "docker", "*.apps"]
    staging_domain_local = ["staging", "console.staging"]
}

data "google_dns_managed_zone" "awanku_id" {
  name = "awanku-id"
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
  rrdatas = local.internal_ingress_ips
}

data "google_dns_managed_zone" "awanku_xyz" {
  name = "awanku-xyz"
}

resource "google_dns_record_set" "awanku_xyz" {
  name = data.google_dns_managed_zone.awanku_xyz.dns_name
  type = "A"
  ttl  = 300

  managed_zone = data.google_dns_managed_zone.awanku_xyz.name
  rrdatas = local.ingress_ips
}

resource "google_dns_record_set" "staging_local_awanku_xyz" {
  for_each = toset(local.staging_domain_local)

  name = "${each.value}.${data.google_dns_managed_zone.awanku_xyz.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = data.google_dns_managed_zone.awanku_xyz.name
  rrdatas = ["127.0.0.1"]
}

resource "google_dns_record_set" "staging_internal_awanku_xyz" {
  for_each = toset(local.staging_domain_cnames)

  name = "${each.value}.staging.${data.google_dns_managed_zone.awanku_xyz.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = data.google_dns_managed_zone.awanku_xyz.name
  rrdatas = local.internal_ingress_ips
}

resource "google_dns_record_set" "dev_awanku_xyz" {
  name = "dev.${data.google_dns_managed_zone.awanku_xyz.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = data.google_dns_managed_zone.awanku_xyz.name
  rrdatas = ["127.0.0.1"]
}

resource "google_dns_record_set" "dev_local_awanku_xyz" {
  for_each = toset(local.cname_domains)

  name = "${each.value}.dev.${data.google_dns_managed_zone.awanku_xyz.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = data.google_dns_managed_zone.awanku_xyz.name
  rrdatas = ["127.0.0.1"]
}
