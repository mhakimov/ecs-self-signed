resource "aws_ecr_repository" "ecr_repo" {
  name                 = "fargate-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "envoy_repo" {
  name                 = "envoy-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecs_cluster" "cluster" {
  name = "hello-fargate"
  setting {
    name  = "containerInsights"
    value = "disabled"
    # value = "enabled"
  }
}

resource "aws_ecs_task_definition" "my_task" {
  family                   = var.service_name
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  cpu    = "256" # CPU units
  memory = "512" # GB

  container_definitions = jsonencode([
    {
    image        = "${aws_ecr_repository.ecr_repo.repository_url}:latest",
    name         = "service"
    cpu = 0
  },

  {
    environment : [
      {name = "DNS_NAME", value = "${var.service_name}.awsblogs.info"}
    ],
    image        = "${aws_ecr_repository.envoy_repo.repository_url}:latest",
    name         = "envoy",
    logConfiguration = {
      logDriver = "awslogs",
      options = {
        awslogs-group = "/ecs/ecs_encryption",
        awslogs-region = "eu-west-2",
        awslogs-stream-prefix = "ecs"
      }
    },
    portMappings = [
      { 
        containerPort = 443,
        hostPort      = 443
 }],
    cpu = 0,
    
  }
  ])
}

resource "aws_ecs_service" "bar" {
  name            = "test-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.my_task.arn
  desired_count   = 1
  network_configuration {
    subnets         = [aws_subnet.private_aza.id, aws_subnet.private_azb.id]
    //according to aws tut lb and ecs share same sg
    # security_groups = [aws_security_group.ecs_security_group.id]
    security_groups = [aws_security_group.lb_sg.id]

    assign_public_ip = true
  }
  launch_type = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_target_group.arn
    container_name   = var.container_name
    container_port   = 443
  }
  deployment_maximum_percent = 200
  deployment_minimum_healthy_percent = 100

}