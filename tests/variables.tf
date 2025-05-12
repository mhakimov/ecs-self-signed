variable "aws_region" {}
variable "source_eni_id" {
  type        = string
  description = "ENI ID of the ECS Fargate task to mirror traffic from"
}

# variable "vpc_id" {}
variable "tfe_token" {}
# variable "tf_cloud_organisation" {
#   description = "name of organisation in your TF Cloud account"
# }

# variable "tf_cloud_workspace" {
#   description = "name of workspace in your TF Cloud organisation"
# }
