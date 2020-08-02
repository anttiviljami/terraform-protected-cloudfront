provider "aws" {
  region = var.region
}

module "protected_cloudfront" {
  source = "../../"

  name                = var.name
  root_domain         = var.root_domain
  subdomains          = var.subdomains
  acm_certificate_arn = var.acm_certificate_arn
  allowlist_ipv4      = var.allowlist_ipv4
  allowlist_ipv6      = var.allowlist_ipv6

  default_origin = {
    domain_name = "protected-cloudfront-demo-app.s3-website-eu-west-1.amazonaws.com"
    origin_path = ""
    custom_origin_config = {
      http_port                = 80
      https_port               = 443
      origin_read_timeout      = 60
      origin_keepalive_timeout = 10
      origin_ssl_protocols     = ["TLSv1.2"]
      origin_protocol_policy   = "http-only"
      # WARNING: Traffic should be secured between cloudfront and origins
      # S3 website hosting is always unsecured HTTP 
    }
  }
  forwarded_headers = ["Authorization", "Referrer"]

  tags = {
    Service = "My Protected Application"
    Author  = "viljami.io"
  }
}
