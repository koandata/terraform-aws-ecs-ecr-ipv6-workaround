output "secret_arn" {
  description = "Secret ARN to read the secret from"
  value       = aws_secretsmanager_secret.ecr.arn
}
output "ecr_proxy_domain" {
  description = "ECR Proxy domain name to proxy ECR as direct access is currently broken"
  value       = aws_cloudfront_distribution.ecr_proxy.domain_name
}
