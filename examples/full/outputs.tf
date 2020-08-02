output "distribution_arn" {
  value = module.protected_cloudfront.distribution_arn
}

output "distribution_id" {
  value = module.protected_cloudfront.distribution_id
}

output "distribution_domain_name" {
  value = module.protected_cloudfront.distribution_domain_name
}

output "static_bucket" {
  value = module.protected_cloudfront.static_bucket
}

output "static_bucket_arn" {
  value = module.protected_cloudfront.static_bucket_arn
}
