This terraform module works around the ECR issue with ECS when it doesn't use an IAM role due to a new repository scheme.

It's only useful until <https://github.com/aws/containers-roadmap/issues/2611> gets fixed.

The output cloudfront_domain_name contains the name for the ECR Proxy as AWS broke direct access to the new IPv6-enabled endpoint - <https://github.com/aws/containers-roadmap/issues/1340#issuecomment-3177231396>
Use it in your task definition as `"${module.ecr_workaround.ecr_proxy_domain}/{your_repo}:{your_tag}"` instead of `{account_id}.dkr-ecr.ap-southeast-2.on.aws/{your_repo}:{your_tag}`.

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_archive"></a> [archive](#provider\_archive) | n/a |
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudfront_distribution.ecr_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_distribution) | resource |
| [aws_cloudwatch_event_rule.every_11_hours](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.lambda_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_iam_role.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_function.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_invocation.oneoff](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_invocation) | resource |
| [aws_lambda_permission.allow_cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_secretsmanager_secret.ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [random_pet.random](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/pet) | resource |
| [archive_file.lambda](https://registry.terraform.io/providers/hashicorp/archive/latest/docs/data-sources/file) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_cloudfront_cache_policy.nocache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_cache_policy) | data source |
| [aws_cloudfront_origin_request_policy.nohost](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_origin_request_policy) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ecr_repo_arn"></a> [ecr\_repo\_arn](#input\_ecr\_repo\_arn) | Arn of the ecr repo | `string` | `""` | no |
| <a name="input_ecr_repo_arns"></a> [ecr\_repo\_arns](#input\_ecr\_repo\_arns) | Arns of the ecr repos we want to have access to | `list` | `[]` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Name prefix to use for resources | `string` | `"ecs-ecr-ipv6-workaround-"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecr_proxy_domain"></a> [ecr\_proxy\_domain](#output\_ecr\_proxy\_domain) | ECR Proxy domain name to proxy ECR as direct access is currently broken |
| <a name="output_secret_arn"></a> [secret\_arn](#output\_secret\_arn) | Secret ARN to read the secret from |
<!-- END_TF_DOCS -->
