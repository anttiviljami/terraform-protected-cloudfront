resource "aws_cloudfront_distribution" "main" {
  comment = var.name
  tags    = var.tags

  enabled         = true
  is_ipv6_enabled = true

  price_class = "PriceClass_100"

  aliases = var.aliases

  origin {
    origin_id   = "static"
    domain_name = aws_s3_bucket.static_bucket.bucket_regional_domain_name
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.static_bucket.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    target_origin_id       = "static" #TODO
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    forwarded_values {
      cookies {
        forward = "none"
      }
      query_string = false
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
