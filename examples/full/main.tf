provider "aws" {
  region = var.region
}

module "protected_cloudfront" {
  source = "../../"

  name                = var.name
  root_domain         = var.root_domain
  subdomains          = ["a.${var.root_domain}", "b.${var.root_domain}"]
  acm_certificate_arn = "arn:aws:acm:us-east-1:921809084865:certificate/2387a941-4dde-4ba3-8709-f456ed223d26"
  allowlist_ipv4      = ["10.0.0.0/8"]
  allowlist_ipv6      = ["2001:db8::/64"]
  forwarded_headers   = ["Authorization"]
  tags = {
    Author = "viljami.io"
  }
}

