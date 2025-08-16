resource "aws_cloudfront_distribution" "ecr_proxy" {
  origin {
    domain_name = "${data.aws_caller_identity.current.account_id}.dkr-ecr.ap-southeast-2.on.aws"
    origin_id   = "ecr"

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = ["TLSv1.2"]
      origin_read_timeout      = 60
      origin_keepalive_timeout = 5
    }
  }
  enabled         = true
  is_ipv6_enabled = true
  comment         = "${var.name_prefix}${random_pet.random.id}-proxy"

  default_cache_behavior {
    // Using the CachingDisabled managed policy
    cache_policy_id = data.aws_cloudfront_cache_policy.nocache.id

    // Managed-AllViewerExceptHostHeader
    origin_request_policy_id = data.aws_cloudfront_origin_request_policy.nohost.id
    allowed_methods          = ["GET", "HEAD", "OPTIONS"]
    cached_methods           = ["GET", "HEAD"]
    target_origin_id         = "ecr"
    viewer_protocol_policy   = "redirect-to-https"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
