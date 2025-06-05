resource "aws_ecr_repository" "app_repo" {
  name                 = "app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "envoy_repo" {
  name                 = "proxy"
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

resource "aws_ecs_task_definition" "my_task" {
  task_role_arn            = aws_iam_role.ecs_execution_role.arn
  family                   = "sample-fargate"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  cpu    = "256" # CPU units
  memory = "512" # GB

  container_definitions = jsonencode([
    {
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "/ecs/ecs-self-signed",
          awslogs-region        = "${var.aws_region}",
          awslogs-stream-prefix = "ecs"
        }
      },
      portMappings = [
        {
          hostPort      = 443,
          protocol      = "tcp",
          containerPort = 443
        }
      ],
      cpu = 0,
      environment = [
        {
          name  = "DNS_NAME",
          value = "ecs-ss.m-computing.org"
        }
      ],
      image = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/proxy:latest",
      name  = "envoy"
    },

    {
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "/ecs/ecs-self-signed",
          awslogs-region        = "${var.aws_region}",
          awslogs-stream-prefix = "ecs"
        }
      },
      cpu   = 0,
      image = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/app:latest"
      name  = "service"
    }
  ])
}


resource "aws_ecs_service" "bar" {
  name            = "test-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.my_task.arn
  desired_count   = 2
  network_configuration {
    subnets          = [aws_subnet.private_aza.id]
    security_groups  = [aws_security_group.ecs_security_group.id]
    assign_public_ip = false
  }
  launch_type = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_target_group.arn
    container_name   = "envoy"
    container_port   = 443
  }

}
