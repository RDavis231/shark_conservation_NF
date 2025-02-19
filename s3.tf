# Create an S3 bucket
resource "aws_s3_bucket" "sharkblog-alb-logs" {
  bucket = "sharkblog-alb-logs"

  tags = {
    Name        = "sharkblog"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.sharkblog-alb-logs.id
  versioning_configuration {
    status = "Enabled"
  }
}
