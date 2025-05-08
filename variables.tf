variable "ecr_repo_arn" {
  description = "arn of the ecr repo"
  type        = string
}
variable "name_prefix" {
  description = "Name prefix to use for resources"
  type        = string
  default     = "ecs-ecr-ipv6-workaround-"
}
