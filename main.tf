resource "aws_cloudfront_distribution" "main" {
  comment = var.name
  tags    = var.tags

  enabled         = true
  is_ipv6_enabled = true

  price_class = "PriceClass_100"

  aliases = var.root_domain != "" ? local.aliases : []

  origin {
    origin_id   = "default"
    domain_name = var.default_origin.domain_name
    origin_path = lookup(var.default_origin, "origin_path", "")
    custom_origin_config {
      http_port                = lookup(var.default_origin.custom_origin_config, "http_port", 80)
      https_port               = lookup(var.default_origin.custom_origin_config, "https_port", 443)
      origin_protocol_policy   = lookup(var.default_origin.custom_origin_config, "origin_protocol_policy", "https-only")
      origin_ssl_protocols     = lookup(var.default_origin.custom_origin_config, "origin_ssl_protocols", ["TLSv1.2"])
      origin_keepalive_timeout = lookup(var.default_origin.custom_origin_config, "origin_keepalive_timeout", 60)
      origin_read_timeout      = lookup(var.default_origin.custom_origin_config, "origin_read_timeout", 60)
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
    path_pattern           = "/static/*"
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
    minimum_protocol_version       = "TLSv1"
  }
}

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

# Route53 Alias with both IPv4 and IPv6 doesn't seem to work for whatever reason
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
