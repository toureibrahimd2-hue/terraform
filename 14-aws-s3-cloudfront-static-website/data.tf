data "aws_caller_identity" "current" {}
data "aws_region" "current" {}


data "aws_iam_policy_document" "allow_cf" {

  statement {
    sid    = "AllowCloudFrontServicePrincipalReadOnly"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]

    resources = [
      aws_s3_bucket.website.arn,
      "${aws_s3_bucket.website.arn}/*"
    ]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"

      values = [
      aws_cloudfront_distribution.s3_distribution.arn
      ]      
    }
  }
}
