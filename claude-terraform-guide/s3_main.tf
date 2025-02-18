# Configure the AWS Provider
provider "aws" {
  region = "us-east-1" # Replace with your desired region
}

# Generate a random string for bucket name uniqueness
resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Create S3 bucket with versioning enabled
resource "aws_s3_bucket" "my_bucket" {
  # Bucket naming convention: project-purpose-randomstring
  bucket = "claude-terraform-${random_string.bucket_suffix.result}"

  # Prevent accidental deletion of this S3 bucket
  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "Claude Terraform Demo"
    Environment = "Dev"
    CreatedBy   = "Terraform"
  }
}

# Configure bucket ownership controls first
resource "aws_s3_bucket_ownership_controls" "my_bucket_ownership" {
  bucket = aws_s3_bucket.my_bucket.id
  
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Configure ACL after ownership controls
resource "aws_s3_bucket_acl" "my_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.my_bucket_ownership]
  
  bucket = aws_s3_bucket.my_bucket.id
  acl    = "private"
}

# Output the bucket name
output "bucket_name" {
  description = "Name of the created S3 bucket"
  value       = aws_s3_bucket.my_bucket.id
}