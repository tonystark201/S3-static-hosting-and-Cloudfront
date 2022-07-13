
output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.s3_distribution.domain_name
}

output "cloudfront_dist_id" {
  value = aws_cloudfront_distribution.s3_distribution.id
}

output "s3_domain_name" {
  value = aws_s3_bucket.demo_website.website_domain
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.demo_website.arn
}

output "s3_bucket_name" {
  value = aws_s3_bucket.demo_website.id
}