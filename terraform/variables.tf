variable "region" {
  type    = string
  default = "us-east-1"
}

variable "project" {
  type    = string
  default = "banking-user-service"
}

variable "avatars_bucket_prefix" {
  description = "Prefix for S3 bucket to store user avatars"
  type        = string
  default     = "avatarsbucket"
}