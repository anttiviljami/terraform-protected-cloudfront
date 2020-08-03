##
# CloudFront Distribution
##
resource "aws_cloudfront_distribution" "main" {
  comment = var.name
  tags    = var.tags

  enabled         = true
  is_ipv6_enabled = true

  price_class = var.price_class

  aliases = var.root_domain != "" ? local.aliases : []

  origin {
    origin_id   = "default"
    domain_name = var.default_origin.domain_name
    origin_path = var.default_origin.origin_path
    custom_origin_config {
      http_port                = var.default_origin.custom_origin_config.http_port
      https_port               = var.default_origin.custom_origin_config.https_port
      origin_protocol_policy   = var.default_origin.custom_origin_config.origin_protocol_policy
      origin_ssl_protocols     = var.default_origin.custom_origin_config.origin_ssl_protocols
      origin_keepalive_timeout = var.default_origin.custom_origin_config.origin_keepalive_timeout
      origin_read_timeout      = var.default_origin.custom_origin_config.origin_read_timeout
    }
  }

  origin {
    origin_id   = "static"
    domain_name = aws_s3_bucket.static_bucket.bucket_regional_domain_name
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.static_bucket.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    target_origin_id       = "default"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
      headers = var.forwarded_headers
    }
    min_ttl     = 0
    max_ttl     = 86400
    default_ttl = 3600
    compress    = true
  }

  ordered_cache_behavior {
    path_pattern           = "${var.static_path}*"
    target_origin_id       = "static"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      cookies {
        forward = "none"
      }
      query_string = false
      headers      = []
    }
    min_ttl     = 0
    max_ttl     = 86400
    default_ttl = 3600
    compress    = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = var.acm_certificate_arn
    ssl_support_method             = var.acm_certificate_arn == "" ? "" : "sni-only"
    cloudfront_default_certificate = var.acm_certificate_arn == "" ? true : false
    minimum_protocol_version       = var.minimum_tls_version
  }

  web_acl_id = length(local.allowlist_ip) > 0 ? aws_waf_web_acl.ip_allowlist.0.id : null

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.access_logs.bucket_domain_name
    prefix          = ""
  }
}

resource "aws_s3_bucket" "access_logs" {
  bucket = "${var.name}-cloudfront-access-logs"
  tags   = var.tags
  acl    = "private"
  lifecycle {
    # ignore changes made to ACL by CloudFront
    # https://github.com/terraform-providers/terraform-provider-aws/issues/10158
    ignore_changes = [grant]
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  lifecycle_rule {
    id      = "log"
    enabled = true
    prefix  = ""
    tags = {
      "rule"      = "log"
      "autoclean" = "true"
    }
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
    transition {
      days          = 60
      storage_class = "GLACIER"
    }
    expiration {
      days = 90
    }
  }
}

##
# Private Origin S3 Bucket for /static
##
resource "aws_s3_bucket" "static_bucket" {
  bucket = "${var.name}-static"
  tags   = var.tags
  acl    = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  versioning {
    enabled = true
  }
}

resource "aws_cloudfront_origin_access_identity" "static_bucket" {
  comment = var.name
}

data "aws_iam_policy_document" "static_bucket" {
  statement {
    sid = "CloudFrontReadOnly"
    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        aws_cloudfront_origin_access_identity.static_bucket.iam_arn,
      ]
    }
    resources = [
      aws_s3_bucket.static_bucket.arn,
      "${aws_s3_bucket.static_bucket.arn}/*",
    ]
  }
  statement {
    sid     = "EnforceTLS"
    actions = ["s3:*"]
    condition {
      test     = "Bool"
      values   = ["false"]
      variable = "aws:SecureTransport"
    }
    effect = "Deny"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [
      aws_s3_bucket.static_bucket.arn,
      "${aws_s3_bucket.static_bucket.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "static_bucket" {
  bucket = aws_s3_bucket.static_bucket.id
  policy = data.aws_iam_policy_document.static_bucket.json
}

##
# Route53 Hosted Zone 
##
resource "aws_route53_zone" "main" {
  count = var.root_domain != "" ? 1 : 0
  name  = var.root_domain
  tags  = var.tags
}

resource "aws_route53_record" "cloudfront-ipv4" {
  count   = length(local.aliases)
  zone_id = aws_route53_zone.main[0].zone_id
  name    = local.aliases[count.index]
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = false
  }
}

# @FIXME: Route53 Alias with both IPv4 and IPv6 doesn't seem to work for whatever reason

# resource "aws_route53_record" "cloudfront-ipv6" {
#   count   = length(local.aliases)
#   zone_id = aws_route53_zone.main[0].zone_id
#   name    = local.aliases[count.index]
#   type    = "AAAA"
#   alias {
#     name                   = aws_cloudfront_distribution.main.domain_name
#     zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
#     evaluate_target_health = false
#   }
# }

##
# AWS WAF Web ACL IP Protection
#
# Note: The new WAFv2 resources for CloudFront can currently only be created in us-east-1
# TODO: Move to another module with us-east-1 provider
##
resource "aws_waf_ipset" "ip_allowlist" {
  count = length(local.allowlist_ip) > 0 ? 1 : 0

  name = "${var.name}-ip-whitelist"
  dynamic "ip_set_descriptors" {
    for_each = var.allowlist_ipv4
    content {
      type  = "IPV4"
      value = ip_set_descriptors.value
    }
  }
  dynamic "ip_set_descriptors" {
    for_each = var.allowlist_ipv6
    content {
      type  = "IPV6"
      value = ip_set_descriptors.value
    }
  }
}

resource "aws_waf_rule" "ip_allowlist" {
  count = length(local.allowlist_ip) > 0 ? 1 : 0

  name        = "${var.name}-ip-whitelist"
  metric_name = "WafRule${sha256(var.name)}"
  predicates {
    type    = "IPMatch"
    data_id = aws_waf_ipset.ip_allowlist.0.id
    negated = false
  }
}

resource "aws_waf_web_acl" "ip_allowlist" {
  count = length(local.allowlist_ip) > 0 ? 1 : 0

  name        = "${var.name}-ip-whitelist-acl"
  metric_name = "ACL${sha256(var.name)}"

  rules {
    rule_id = aws_waf_rule.ip_allowlist.0.id
    action {
      type = "ALLOW"
    }
    priority = 1
    type     = "REGULAR"
  }

  default_action {
    type = "BLOCK"
  }
}

# TODO: Add Basic Auth module
# https://github.com/builtinnya/aws-lambda-edge-basic-auth-terraform
