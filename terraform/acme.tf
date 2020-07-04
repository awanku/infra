provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

resource "tls_private_key" "awanku" {
  algorithm = "RSA"
}

resource "acme_registration" "awanku" {
  account_key_pem = tls_private_key.awanku.private_key_pem
  email_address   = "arba.sasmoyo@gmail.com"
}

resource "acme_certificate" "awanku_id" {
  account_key_pem           = acme_registration.awanku.account_key_pem
  common_name               = "awanku.id"
  subject_alternative_names = ["*.awanku.id", "*.apps.awanku.id", "*.internal.awanku.id"]
  recursive_nameservers     = ["1.1.1.1", "8.8.8.8"]

  dns_challenge {
    provider = "gcloud"
    config = {
      GCE_PROJECT = "awanku"
    }
  }
}

data "template_file" "awanku_id_key" {
  template = file("ssl_private_key.tpl")
  vars = {
    private_key = acme_certificate.awanku_id.private_key_pem
  }
}

resource "local_file" "awanku_id_key" {
  content  = data.template_file.awanku_id_key.rendered
  filename = "awanku_id.key"
}

data "template_file" "awanku_id_crt" {
  template = file("ssl_certificate.tpl")
  vars = {
    intermediate_key = acme_certificate.awanku_id.issuer_pem
    certificate_key = acme_certificate.awanku_id.certificate_pem
  }
}

resource "local_file" "awanku_id_crt" {
  content  = data.template_file.awanku_id_crt.rendered
  filename = "awanku_id.crt"
}

resource "acme_certificate" "awanku_xyz" {
  account_key_pem           = acme_registration.awanku.account_key_pem
  common_name               = "awanku.xyz"
  subject_alternative_names = ["staging.awanku.xyz", "*.staging.awanku.xyz", "*.apps.staging.awanku.xyz"]
  recursive_nameservers     = ["1.1.1.1", "8.8.8.8"]

  dns_challenge {
    provider = "gcloud"
    config = {
      GCE_PROJECT = "awanku"
    }
  }
}

data "template_file" "awanku_xyz_key" {
  template = file("ssl_private_key.tpl")
  vars = {
    private_key = acme_certificate.awanku_xyz.private_key_pem
  }
}

resource "local_file" "awanku_xyz_key" {
  content  = data.template_file.awanku_xyz_key.rendered
  filename = "awanku_xyz.key"
}

data "template_file" "awanku_xyz_crt" {
  template = file("ssl_certificate.tpl")
  vars = {
    intermediate_key = acme_certificate.awanku_xyz.issuer_pem
    certificate_key = acme_certificate.awanku_xyz.certificate_pem
  }
}

resource "local_file" "awanku_xyz_crt" {
  content  = data.template_file.awanku_xyz_crt.rendered
  filename = "awanku_xyz.crt"
}
