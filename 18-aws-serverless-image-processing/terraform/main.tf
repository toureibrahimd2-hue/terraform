
# ============================================================================
# LOCALS
# ============================================================================
locals {
  lambda_function_name = "${var.project_name}-image-processor"
  upload_bucket_name    = "${var.project_name}-upload-${data.aws_caller_identity.current.account_id}"
  processed_bucket_name = "${var.project_name}-processed-${data.aws_caller_identity.current.account_id}"
}

# ============================================================================
# S3 - BUCKET SOURCE (uploads)
# ============================================================================
resource "aws_s3_bucket" "upload_bucket" {
  bucket = local.upload_bucket_name
}

resource "aws_s3_bucket_versioning" "upload_versioning" {
  bucket = aws_s3_bucket.upload_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "upload_encryption" {
  bucket = aws_s3_bucket.upload_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "upload_block" {
  bucket                  = aws_s3_bucket.upload_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ============================================================================
# S3 - BUCKET DESTINATION (processed)
# ============================================================================
resource "aws_s3_bucket" "processed_bucket" {
  bucket = local.processed_bucket_name
}

resource "aws_s3_bucket_versioning" "processed_versioning" {
  bucket = aws_s3_bucket.processed_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "processed_encryption" {
  bucket = aws_s3_bucket.processed_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "processed_block" {
  bucket                  = aws_s3_bucket.processed_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}



# ============================================================================
# IAM ROLE POUR LA LAMBDA
# ============================================================================
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "${var.project_name}-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.lambda_processor.arn}:*"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.upload_bucket.arn}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = "${aws_s3_bucket.processed_bucket.arn}/*"
      }
    ]
  })
}

# ============================================================================
# CLOUDWATCH LOG GROUP (créé explicitement AVANT la Lambda)
# ============================================================================
resource "aws_cloudwatch_log_group" "lambda_processor" {
  name              = "/aws/lambda/${local.lambda_function_name}"
  retention_in_days = 14
}


# ============================================================================
# LAMBDA LAYER (Pillow)
# ============================================================================
resource "aws_lambda_layer_version" "pillow_layer" {
  filename            = "${path.module}/../lambda/layer/pillow_layer.zip"
  layer_name          = "${var.project_name}-pillow-layer"
  compatible_runtimes = ["python3.12"]
  description         = "Pillow library for image processing"
  source_code_hash    = filebase64sha256("${path.module}/../lambda/layer/pillow_layer.zip")
}

# ============================================================================
# PACKAGING DU CODE LAMBDA
# ============================================================================

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../lambda/src"
  output_path = "${path.module}/../lambda/build/lambda_function.zip"
}

# ============================================================================
# FONCTION LAMBDA
# ============================================================================
resource "aws_lambda_function" "image_processor" {
  function_name = local.lambda_function_name
  filename      = data.archive_file.lambda_zip.output_path
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.12"
  role          = aws_iam_role.lambda_role.arn
  timeout       = 60
  memory_size   = 1024

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  layers = [aws_lambda_layer_version.pillow_layer.arn]

  environment {
    variables = {
      PROCESSED_BUCKET = aws_s3_bucket.processed_bucket.id
      LOG_LEVEL         = "INFO"
    }
  }

  # Garantit que le log group existe AVANT la première invocation
  depends_on = [aws_cloudwatch_log_group.lambda_processor]
}

# ============================================================================
# S3 EVENT TRIGGER
# ============================================================================
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.image_processor.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.upload_bucket.arn
}

resource "aws_s3_bucket_notification" "upload_bucket_notification" {
  bucket = aws_s3_bucket.upload_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.image_processor.arn
    events               = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}