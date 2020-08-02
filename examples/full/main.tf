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
  allowlist_ipv6 = ["2001:0db8:0000:0000:0000:0000:0000:0000/64"]

  default_origin = {
    domain_name = "protected-cloudfront-demo-app.s3-website-eu-west-1.amazonaws.com"
    origin_path = ""
    custom_origin_config = {
      http_port                = 80
      https_port               = 443
      origin_read_timeout      = 60
      origin_keepalive_timeout = 10
      origin_ssl_protocols     = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      origin_protocol_policy   = "http-only"
    }
  }

  tags = {
    Author = "viljami.io"
  }
}
