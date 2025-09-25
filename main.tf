provider "aws" {
  region = "us-east-1"
}

# 1. The S3 Bucket Resource (FIXED: Removed object_ownership)
resource "aws_s3_bucket" "website_bucket" {
  bucket = "dawitsamuel-cicd-website-bucket-2025" # <--- YOUR UNIQUE NAME
  
  # REMOVE THE LINE object_ownership = "BucketOwnerPreferred"
  
  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

# 2. NEW RESOURCE: Object Ownership Controls
# This explicitly sets the rule that allows public access with policies
resource "aws_s3_bucket_ownership_controls" "ownership_controls" {
  bucket = aws_s3_bucket.website_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# 3. The Public Read Policy (Policy for public access)
resource "aws_s3_bucket_policy" "public_read_policy" {
  bucket = aws_s3_bucket.website_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = [
          "${aws_s3_bucket.website_bucket.arn}/*",
        ],
      },
    ],
  })
}

# 4. The Public Access Block
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.website_bucket.id
  
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

output "website_endpoint" {
  value = "http://${aws_s3_bucket.website_bucket.website_endpoint}"
}