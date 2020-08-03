# terraform-protected-cloudfront

[![CI](https://github.com/anttiviljami/terraform-protected-cloudfront/workflows/CI/badge.svg)](https://github.com/anttiviljami/terraform-protected-cloudfront/actions?query=workflow%3ACI)
[![License](https://img.shields.io/badge/license-Apache-blue)](https://github.com/anttiviljami/terraform-protected-cloudfront/blob/master/LICENSE)
![Version](https://img.shields.io/github/v/tag/anttiviljami/terraform-protected-cloudfront)

Terraform module to create a [CloudFront distribution](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/distribution-overview.html)
with HTTPS and IP protection adhering to AWS best practices.

This module creates:

- [Cloudfront Distribution](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/distribution-overview.html)
  - Fully configurable default origin
  - TLS with existing ACM Certificate
- Private [S3 bucket](https://docs.aws.amazon.com/AmazonS3/latest/dev/Introduction.html) served under `/static`
- [WAF Web ACL](https://docs.aws.amazon.com/waf/latest/developerguide/web-acl.html) for IP protection
- [Route53 HostedZone](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/hosted-zones-working-with.html) + ALIAS records for configured domains

## Usage

```hcl
module "protected_cloudfront" {
  source "git::https://github.com/anttiviljami/terraform-protected-cloudfront.git?ref=tags/1.1.1"

  name                = "my-protected-app"
  root_domain         = "terraform.viljami.io"
  subdomains          = ["a.terraform.viljami.io", "b.terraform.viljami.io"]
  acm_certificate_arn = "arn:aws:acm:us-east-1:921809084865:certificate/d453c7e7-b9e4-430b-a380-113cffd924e3"

  allowlist_ipv4 = ["10.0.0.0/16", "8.0.0.0/8"]
  allowlist_ipv6 = ["2001:db8::/64"]

  default_origin = {
    domain_name = "my-protected-app.viljami.io"
    origin_path = ""
    custom_origin_config = {
      http_port                = 80
      https_port               = 443
      origin_read_timeout      = 60
      origin_keepalive_timeout = 10
      origin_ssl_protocols     = ["TLSv1.2"]
      origin_protocol_policy   = "https-only"
    }
  }
  forwarded_headers = ["Authorization", "Referrer"]
  static_path       = "/static"

  tags = {
    Service = "My Protected Application"
  }
}
```

See full example under [`examples/full`](./examples/full)

## Outputs

See [`outputs.tf`](./outputs.tf)

## Requirements

- [Terraform](https://www.terraform.io/downloads.html) (>0.12.0)

## Tests

This Terraform module is tested using [Terratest](https://terratest.gruntwork.io/). To run:

```sh
cd test && go test
```
