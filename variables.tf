variable "ecr_repo_arn" {
  description = "Arn of the ecr repo"
  default     = ""
  type        = string
}
variable "name_prefix" {
  description = "Name prefix to use for resources"
  type        = string
  default     = "ecs-ecr-ipv6-workaround-"
}
variable "ecr_repo_arns" {
  description = "Arns of the ecr repos we want to have access to"
  default     = []
}
