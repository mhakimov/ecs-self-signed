
resource "aws_ecr_repository" "ecr_repo" {
  name                 = "fargate-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecs_cluster" "cluster" {
  name = "hello-fargate"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}