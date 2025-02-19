# Create an S3 bucket
resource "aws_s3_bucket" "sharkconservation-logs" {
  bucket = "sharkconservation-logs"

  tags = {
    Name        = "sharkconservation"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.sharkconservation-logs.id
  versioning_configuration {
    status = "Enabled"
  }
}
