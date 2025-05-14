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
