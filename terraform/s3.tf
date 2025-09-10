resource "aws_s3_bucket" "avatars" {
  bucket        = "${var.avatars_bucket_prefix}-${random_id.bucket_suffix.hex}"
  force_destroy = true
  tags = {
    Name    = "AvatarsBucket"
    Project = var.project
  }
}