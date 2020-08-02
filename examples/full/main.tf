provider "aws" {
  region = var.region
}

module "protected_cloudfront" {
  source = "../../"

  name                = var.name
  root_domain         = var.root_domain
  subdomains          = var.subdomains
  acm_certificate_arn = var.acm_certificate_arn

  allowlist_ipv4 = ["10.0.0.0/8"]
  allowlist_ipv6 = ["2001:db8::/64"]

  tags = {
    Author = "viljami.io"
  }
}
