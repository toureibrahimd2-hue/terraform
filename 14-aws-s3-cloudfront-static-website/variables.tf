# variables.tf

variable "aws_region" {
  description = "The AWS region to create resources in."
  type        = string
  default     = "eu-north-1"
}

variable "bucket_prefix" {
  description = "Name of the S3 bucket."
  type        = string
  default     = "my-tf-test-bucket-an"
}