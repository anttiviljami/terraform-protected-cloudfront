# terraform-protected-cloudfront

[![License](https://img.shields.io/github/license/anttiviljami/terraform-protected-cloudfront)](https://github.com/anttiviljami/terraform-protected-cloudfront/blob/master/LICENSE)
[![CI](https://github.com/anttiviljami/terraform-protected-cloudfront/workflows/CI/badge.svg)](https://github.com/anttiviljami/terraform-protected-cloudfront/actions?query=workflow%3ACI)

Terraform module to create a [CloudFront distribution](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/distribution-overview.html)
with HTTPS and IP protection adhering to AWS best practices.

- [Cloudfront Distribution](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/distribution-overview.html)
  - Serves static content from private S3 bucket under /static
  - Configurable default behaviour
  - HTTPS
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

## Inputs

- ACM Certificate ARN for HTTPS
- Domain Name(s) associated with certificate
- Allowed IP ranges (default: 0.0.0.0/0, ::/0)
- Default CloudFront Origin (default: External demo app)
- Root path to serve static S3 content (default: /static)
- Basic Auth Configuration (optional)
- Tags (optional)

## Outputs

- Distribution ARN
- Distribution ID
- Distribution Domain Name
- Static S3 Bucket Name
- Static S3 Bucket ARN

## Tests

This Terraform module is tested using [Terratest](https://terratest.gruntwork.io/). To run:

```sh
cd test && go test
```