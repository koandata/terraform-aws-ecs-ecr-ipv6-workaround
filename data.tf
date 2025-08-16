data "aws_caller_identity" "current" {}

data "aws_cloudfront_origin_request_policy" "nohost" {
  name = "Managed-AllViewerExceptHostHeader"
}

data "aws_cloudfront_cache_policy" "nocache" {
  name = "Managed-CachingDisabled"
}
