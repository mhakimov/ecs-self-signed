resource "aws_cloudwatch_log_group" "yada" {
  name = "/ecs/ecs-self-signed"

  tags = {
    Terraform = true
  }
}
