# terraform-protected-cloudfront

[![CI](https://github.com/anttiviljami/terraform-protected-cloudfront/workflows/CI/badge.svg)](https://github.com/anttiviljami/terraform-protected-cloudfront/actions?query=workflow%3ACI)
[![License](https://img.shields.io/github/license/anttiviljami/terraform-protected-cloudfront)](https://github.com/anttiviljami/terraform-protected-cloudfront/blob/master/LICENSE)

Terraform module to create a [CloudFront distribution](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/distribution-overview.html)
with HTTPS and IP protection adhering to AWS best practices.

- [Cloudfront Distribution](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/distribution-overview.html)
  - Configurable default origin
  - Creates private S3 bucket to serve content under /static
  - HTTPS with existing ACM Certificate
- [WAF Web ACL](https://docs.aws.amazon.com/waf/latest/developerguide/web-acl.html)
  - IP Whitelist (IPv4 + IPv6)
- [Route53 HostedZone](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zones-working-with.html)
- Basic Auth with [Lambda@Edge](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-at-the-edge.html)

## Usage

```hcl
module "protected_cloudfront" {
  source "git::https://github.com/anttiviljami/terraform-protected-cloudfront.git?ref=master"

  name                = var.name
  root_domain         = "terraform.viljami.io"
  subdomains          = ["www.terraform.viljami.io"]
  acm_certificate_arn = "arn:aws:acm:us-east-1:921809084865:certificate/d453c7e7-b9e4-430b-a380-113cffd924e3"
  allowlist_ipv4      = ["10.0.0.0/8"]
  allowlist_ipv6      = ["2001:db8::/64"]
  forwarded_headers   = ["Authorization"]
  tags = {
    Author = "viljami.io"
  }
}
```

## Requirements

- Terraform (>0.12.0)
- AWS Provider (>3.0.0)

## Tests

This Terraform module is tested using [Terratest](https://terratest.gruntwork.io/). To run:

```sh
cd test && go test
```
