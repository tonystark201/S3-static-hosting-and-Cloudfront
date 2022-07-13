resource "random_pet" "bucket_name" {
  prefix = "cdn"
  length = 4
}

###################
# S3 Bucket 
###################
resource "aws_s3_bucket" "demo_website" {
  bucket = random_pet.bucket_name.id
  force_destroy = true
}

resource "aws_s3_bucket_acl" "demo_website_acl" {
  bucket = aws_s3_bucket.demo_website.id
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "demo_website_policy" {
  bucket = aws_s3_bucket.demo_website.id
  policy = jsonencode(
    {
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "PublicReadGetObject",
                "Effect": "Allow",
                "Principal": "*",
                "Action": [
                    "s3:GetObject"
                ],
                "Resource": [
                    "arn:aws:s3:::${aws_s3_bucket.demo_website.id}/*"
                ]
            }
        ]
    }
  )
}

resource "aws_s3_bucket_website_configuration" "example" {
  bucket = aws_s3_bucket.demo_website.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }

}

resource "aws_s3_bucket_object" "index" {
  bucket       = aws_s3_bucket.demo_website.bucket
  key          = "index.html"
  source       = "${path.module}/index.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/index.html")
}

resource "aws_s3_bucket_object" "error" {
  bucket       = aws_s3_bucket.demo_website.bucket
  key          = "error.html"
  source       = "${path.module}/error.html"
  content_type = "text/html"
  etag         = filemd5("${path.module}/error.html")
}

###################
# Cloudfront
###################
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.demo_website.bucket_regional_domain_name}"
    origin_id   = "${local.s3_origin_id}"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "${local.s3_origin_id}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = var.cloudfront_min_ttl
    default_ttl            = var.cloudfront_default_ttl
    max_ttl                = var.cloudfront_max_ttl
  }

  price_class = var.price_class

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  depends_on = [
    aws_s3_bucket.demo_website
  ]
}