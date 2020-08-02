variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "name" {
  type    = string
  default = "protected-cf-example-full"
}

variable "root_domain" {
  type    = string
  default = "terraform.viljami.io"
}

variable "subdomains" {
  type    = list(string)
  default = ["www.terraform.viljami.io"]
}

variable acm_certificate_arn {
  type    = string
  default = "arn:aws:acm:us-east-1:921809084865:certificate/d453c7e7-b9e4-430b-a380-113cffd924e3"
}
