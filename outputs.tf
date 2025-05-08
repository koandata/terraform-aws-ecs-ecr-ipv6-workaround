output "secret_arn" {
  description = "Secret ARN to read the secret from"
  value       = aws_secretsmanager_secret.ecr.arn
}
