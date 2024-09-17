# AWS S3 Bucket for CodePipeline Artifacts
resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "webapp-codepipeline-bucket" # Ensure this bucket name is unique across AWS
}

# Enable versioning for the S3 bucket
resource "aws_s3_bucket_versioning" "codepipeline_bucket_versioning" {
  bucket = aws_s3_bucket.codepipeline_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}
