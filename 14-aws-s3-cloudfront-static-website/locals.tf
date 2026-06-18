locals {
  bucket= format("my-tf-test-bucket-%s", data.aws_caller_identity.current.account_id)

    s3_origin_id = "s3-${local.bucket}"
}