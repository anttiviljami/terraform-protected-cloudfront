provider "aws" {
  region = var.region
}

module "protected_cloudfront" {
  source = "../../"

  name = var.name
}

