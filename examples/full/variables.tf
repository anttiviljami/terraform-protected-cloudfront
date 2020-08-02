variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "name" {
  type = string
}

variable "root_domain" {
  type = string
}

variable "subdomains" {
  type = list(string)
}

variable acm_certificate_arn {
  type = string
}

variable allowlist_ipv4 {
  type    = list(string)
  default = []
}

variable allowlist_ipv6 {
  type    = list(string)
  default = []
}
