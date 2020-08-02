provider "aws" {
  region = var.region
}

module "protected_cloudfront" {
  source = "../../"

  name                = var.name
  root_domain         = var.root_domain
  subdomains          = ["a.${var.root_domain}", "b.${var.root_domain}"]
  acm_certificate_arn = "arn:aws:acm:us-east-1:921809084865:certificate/d453c7e7-b9e4-430b-a380-113cffd924e3"
  forwarded_headers   = ["Authorization"]
  tags = {
    Author = "viljami.io"
  }
}

