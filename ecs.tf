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
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "my_task" {
  family                   = "sample-fargate"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  cpu    = "256" # CPU units
  memory = "512" # GB

  container_definitions = jsonencode([{
    environment : [
      { name = "NODE_ENV", value = "production" }
    ],
    essential = true,
    image     = "962768705974.dkr.ecr.eu-west-2.amazonaws.com/fargate-repo:latest",
    # image        = "${aws_ecr_repository.ecr_repo.repository_url}:latest",
    name         = "fargate-app",
    portMappings = [{ containerPort = 80 }],
  }])
}

resource "aws_ecs_service" "bar" {
  name            = "test-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.my_task.arn
  desired_count   = 1
  network_configuration {
    subnets          = [aws_subnet.private_aza.id]
    security_groups  = [aws_security_group.lb_sg.id]
    assign_public_ip = false
  }
  launch_type = "FARGATE"

  #   iam_role        = aws_iam_role.foo.arn
  #   depends_on      = [aws_iam_role_policy.foo]

  #   ordered_placement_strategy {
  #     type  = "binpack"
  #     field = "cpu"
  #   }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_target_group.arn
    container_name   = "fargate-app"
    container_port   = 80
  }

  #   placement_constraints {
  #     type       = "memberOf"
  #     expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  #   }
}
