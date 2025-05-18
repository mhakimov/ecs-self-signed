resource "aws_s3_bucket" "utils" {
  bucket = var.s3_bucket_utils

  tags = {
    Terraform = true
  }
}
