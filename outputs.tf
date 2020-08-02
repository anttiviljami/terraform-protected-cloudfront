output "distribution_arn" {
  value       = aws_cloudfront_distribution.main.arn
  description = "CloudFront Distribution ARN"
}

output "distribution_id" {
  value       = aws_cloudfront_distribution.main.id
  description = "CloudFront Distribution ID"
}

output "distribution_domain_name" {
  value       = aws_cloudfront_distribution.main.domain_name
  description = "CloudFront Distribution Domain Name"
}

output "static_bucket" {
  value       = aws_s3_bucket.static_bucket.id
  description = "Name of S3 bucket serving /static"
}

output "static_bucket_arn" {
  value       = aws_s3_bucket.static_bucket.arn
  description = "ARN of S3 bucket serving /static"
}
