variable "aws_region" {}
variable "task_private_ip" {}
variable "source_eni_id" {
  type        = string
  description = "ENI ID of the ECS Fargate task to mirror traffic from"
}

# variable "vpc_id" {}
variable "tfe_token" {}
