provider "aws" {
  region = "eu-north-1"
}


# S3 Bucket
resource "aws_s3_bucket" "nextjs_bucket" {

  bucket = "nextjs-portfolio-bucket-sz"
}

# OWnership Control
resource "aws_s3_bucket_ownership_controls" "nextjs_bucket_ownership_controls" {

  bucket = aws_s3_bucket.nextjs_bucket.id

  rule {
    object_ownership = "BucketOwnerPrefferred"
  }
}


#Block all Public Accesss

resource "aws_s3_bucket_public_access_block" "nextjs_bucket_public_access_block" {

  bucket = aws_s3_bucket.nextjs_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

}

#Bucket ACL

resource "aws_s3_bucket_acl" "nextjs_bucket_acl" {

  bucket = aws_s3_bucket.nextjs_bucket.id

  acl = "public-read"

  depends_on = [aws_s3_bucket_ownership_controls.nextjs_bucket_ownership_controls,
  aws_s3_bucket_public_access_block.nextjs_bucket_public_access_block]

}


#Bucket Policy

resource "aws_s3_bucket_policy" "nextjs_bucket_policy" {
  bucket = aws_s3_bucket.nextjs_bucket.id
  policy = jsonencode(
    ({
      Version = "2012-18-17"
      Statment = [
        {
          Sid       = "PublicReadGetObject"
          Effect    = "Allow"
          Principal = "*"
          Action    = "s3:GetObject"
          resource  = "${aws_s3_bucket.nextjs_bucket.arn}/*"
        }
      ]
    })
  )

}

# Origin access Identity   (OAI)
# its a extra layer for  security which  ensures only cloud front user can access this S3 bucket

resource "aws_cloudfront_origin_access_identity" "Origin_access_identity" {
  comment = "OAI  for Next.JS for portfolio site"


}

# CloudFront Distribution
# CloudFront reduces the latency for Static websites on S3 Globally, it fetches  data from aws cloud Edges for  fast response to end  user
# CloudFront automaticaly scale up the euser demands loike more user come  to acess it, it scalable automatically
resource "aws_cloudfront_distribution" "nextjs_distributor" {
  origin {
domain_name = aws_s3_bucket.nextjs_bucket.bucket_domain_name,
origin_id = "S3-Nextjs-portfolio-bucket"

    s3_origin_config {
origin_access_identity = aws_cloudfront_origin_access_identity.Origin_access_identity.cloudfront_access_identity_path
    }
  }

enabled = true
is_ipv6_enabled = true
comment = "Next.js for portfolio"
default_root_object = "index.html"


default_cache_behavior {
  allowed_methods = [ "GET","HEAD","OPTIONS" ]
  cached_methods = [ "GET","HEAD" ]
  target_origin_id = "S3-Nextjs-portfolio-bucket"


forwarded_values {
  query_string = false
  cookies {
    forward = "none"
  }
}

viewer_protocol_policy = "redirect-to-https"
min_ttl = 0
default_ttl = 3600
max_ttl = 86400

}

restrictions {
  geo_restriction {
    restriction_type = none
  }
}


viewer_certificate {
  cloudfront_default_certificate = true
}


}
