variable "name" {
  type        = string
  description = "Distribution name"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to assign to resources"
}

variable "acm_certificate_arn" {
  type        = string
  description = "ACM Certificate ARN for HTTPS"
  default     = ""
}

variable "root_domain" {
  type        = string
  description = "Root domain for Route53 Hosted Zone in FQDN format"
  default     = ""
}

variable "subdomains" {
  type        = list(string)
  description = "Subdomains associated with ACM certificate in FQDN format"
  default     = []
}

variable "default_origin" {
  description = "The default distribution behaviour"
  type = object({
    domain_name = string
    origin_path = string
    custom_origin_config = object({
      http_port                = number
      https_port               = number
      origin_protocol_policy   = string
      origin_ssl_protocols     = list(string)
      origin_keepalive_timeout = number
      origin_read_timeout      = number
    })
  })

  # Demo SPA app hosted on S3
  default = {
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
}

variable "forwarded_headers" {
  description = "Headers to forward to default origin"
  type        = list(string)
  default     = []
}

variable "allowlist_ipv4" {
  description = "IPv4 CIDR ranges allowed to access the distribution"
  type        = list(string)
  default     = []
}

variable "allowlist_ipv6" {
  description = "IPv6 CIDR ranges allowed to access the distribution"
  type        = list(string)
  default     = []
}
