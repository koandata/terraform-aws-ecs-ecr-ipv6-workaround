// some data resources to discover the current region and account id
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_ecr_repository" "main" {
  name = "example-repo"
}

// the module creates a secret in Secrets Manager and outputs it
module "ecs_ipv6" {
  source = "git::ssh://git@github.com/koandata/terraform-aws-ecs-ecr-ipv6-workaround.git?ref=0.0.1"

  // need to pass the ECR repo ARN in
  ecr_repo_arn = aws_ecr_repository.main.arn
}

// the execution role needs to have access to the secret
resource "aws_iam_role" "execution_role" {
  name = "example-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]
  })
}

// allows access to the secret
resource "aws_iam_role_policy" "secret_read" {
  role = aws_iam_role.execution_role.name
  name = "read_ecr_secret"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "secretsmanager:GetSecretValue"
        Resource = module.ecs_ipv6.secret_arn
        Effect   = "Allow"
      },
    ]
  })
}

resource "aws_ecs_task_definition" "service" {
  family                   = "example-task-definition"
  requires_compatibilities = ["EC2", "FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024

  execution_role_arn = aws_iam_role.execution_role.arn
  container_definitions = jsonencode([
    {
      name = "app"
      // ipv6 version
      image = "${data.aws_caller_identity.current.account_id}.dkr-ecr.${data.aws_region.current.name}.on.aws/${aws_ecr_repository.main.name}:latest"
      repositoryCredentials = {
        // here we use the secret arn
        credentialsParameter = module.ecs_ipv6.secret_arn
      }
      cpu       = 512
      memory    = 1024
      essential = true
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
        }
      ]
    }
  ])
}
