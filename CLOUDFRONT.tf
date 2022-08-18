resource "aws_s3_bucket" "bucketttt95" {
  bucket = "assign-buckettt95"  
  tags = {
    Name        = "Assign_bucket123"
  }  
}
resource "aws_s3_bucket_acl" "b_acl" {
  bucket = aws_s3_bucket.bucketttt95.id
  acl    = "private"
}
resource "aws_s3_bucket_website_configuration" "config" {
  bucket = aws_s3_bucket.bucketttt95.id
   index_document {
    suffix = "index.html"
  }
  error_document {
    key = "/index.html"
  }
}
# UPLOAD OBJECT 
resource "aws_s3_bucket_acl" "c_acl" {
  bucket = aws_s3_bucket.bucketttt95.id
  acl    = "log-delivery-write"
}
locals {
  s3_origin_id = "myS3Origin"
}
# POLICY 
resource "aws_s3_bucket_policy" "Attach_policy" {
  bucket = aws_s3_bucket.bucketttt95.id
  policy = data.aws_iam_policy_document.policy.json
}
data "aws_iam_policy_document" "policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "s3:*",
    ]
    resources = [
      "${aws_s3_bucket.bucketttt95.arn}/*",
    ]
  }
}
resource "aws_cloudfront_origin_access_identity" "example" {
  comment = "Some comment"
}
resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.bucketttt95.bucket_regional_domain_name
    origin_id   = local.s3_origin_id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.example.cloudfront_access_identity_path
    }
  }
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"
  default_root_object = "index.html"
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id
    forwarded_values {
      query_string = false
      headers      = ["Origin"]
      cookies {
        forward = "none"
      }
    }
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
  }
  price_class = "PriceClass_200"
  viewer_certificate {
    cloudfront_default_certificate = true 
    }
    restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}
