
resource "aws_s3_bucket" "website" {
  bucket           =  local.bucket
   
}


resource "aws_s3_bucket_public_access_block" "block" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "example-oac"
  description                       = "Example Policy"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}




resource "aws_s3_bucket_policy" "allow_cf" {
  bucket = aws_s3_bucket.website.id
  depends_on = [ aws_s3_bucket_public_access_block.block ]
  policy = data.aws_iam_policy_document.allow_cf.json

 
}

resource "aws_s3_object" "object" {
  bucket = aws_s3_bucket.website.bucket
  for_each = fileset("${path.module}/www", "**/*")
  key    = each.value
  source = "${path.module}/www/${each.value}"
  content_type = lookup({
    "html" = "text/html"
    "css"  = "text/css"
    "js"   = "application/javascript"
    "png"  = "image/png"
    "jpg"  = "image/jpeg"
    "jpeg" = "image/jpeg"
    "gif"  = "image/gif"
    "icon" = "image/x-icon"
    "svg"  = "image/svg+xml" 
    "txt"  = "text/plain"

    
  }, regex(".*\\.([a-zA-Z0-9]+)$", each.value)[0], "application/octet-stream")
  etag = filemd5("${path.module}/www/${each.value}")
}


resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.website.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    origin_id                = local.s3_origin_id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"
  default_root_object = "index.html"

  # aliases = ["mysite.${local.my_domain}", "yoursite.${local.my_domain}"]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

 

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }


  viewer_certificate {
  cloudfront_default_certificate = true
  }
}