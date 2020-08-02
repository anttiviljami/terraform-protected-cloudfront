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

variable "aliases" {
  type        = list(string)
  description = "Domain Name(s) associated with certificate"
  default     = []
}
