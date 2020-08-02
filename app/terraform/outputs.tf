output "bucket_name" {
  value = aws_s3_bucket.public.id
}

output "s3_website_endpoint" {
  value = aws_s3_bucket.public.website_endpoint
}
