provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

resource "tls_private_key" "awanku_id" {
  algorithm = "RSA"
}

resource "acme_registration" "awanku_id" {
  account_key_pem = tls_private_key.awanku_id.private_key_pem
  email_address   = "arba.sasmoyo@gmail.com"
}

resource "acme_certificate" "awanku_id" {
  account_key_pem           = acme_registration.awanku_id.account_key_pem
  common_name               = "awanku.id"
  subject_alternative_names = ["*.awanku.id", "*.apps.awanku.id"]

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
