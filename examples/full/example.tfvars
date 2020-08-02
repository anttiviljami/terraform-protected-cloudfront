region = "eu-west-1"
name = "protected-cf-example-full"

root_domain = "terraform.viljami.io"
subdomains = ["www.terraform.viljami.io"]
acm_certificate_arn = "arn:aws:acm:us-east-1:921809084865:certificate/d453c7e7-b9e4-430b-a380-113cffd924e3"

allowlist_ipv4 = ["10.0.0.0/8"]
allowlist_ipv6 = ["2001:0db8:0000:0000:0000:0000:0000:0000/64"]
