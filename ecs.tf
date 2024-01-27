resource "aws_ecr_repository" "ecr_repo" {
  name                 = "fargate-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# resource "aws_ecr_repository" "envoy_repo" {
#   name                 = "envoy-repo"
#   image_tag_mutability = "MUTABLE"

#   image_scanning_configuration {
#     scan_on_push = true
#   }
# }

# "cluster": {
#         "clusterArn": "arn:aws:ecs:us-west-1:<account>:cluster/ecs-encryption-cluster",
#         "clusterName": "ecs-encryption-cluster",
#         "status": "ACTIVE",
#         "registeredContainerInstancesCount": 0,
#         "runningTasksCount": 0,
#         "pendingTasksCount": 0,
#         "activeServicesCount": 0,
#         "statistics": [],
#         "tags": [],
#         "settings": [
#             {
#                 "name": "containerInsights",
#                 "value": "disabled"
#             }
#         ],
#         "capacityProviders": [],
#         "defaultCapacityProviderStrategy": []
#     }

resource "aws_ecs_cluster" "cluster" {
  name = "hello-fargate"
  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}



resource "aws_ecs_task_definition" "my_task" {
  task_role_arn = aws_iam_role.ecs_execution_role.arn
  family                   = "sample-fargate"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn

  cpu    = "256" # CPU units
  memory = "512" # GB

  container_definitions = jsonencode([
  #   {
  #   environment : [
  #     { name = "NODE_ENV", value = "production" }
  #   ],
  #   essential = true,
  #   image = "962768705974.dkr.ecr.eu-west-2.amazonaws.com/ttest:latest",
  #   # image        = "${aws_ecr_repository.ecr_repo.repository_url}:latest",
  #   name         = "fargate-app",
  #   portMappings = [{ containerPort = 80 }],
  # },

      {
       logConfiguration = {
         logDriver = "awslogs",
         options = {
          awslogs-group = "/ecs/ecs-self-signed",
          awslogs-region = "eu-west-2",
          awslogs-stream-prefix = "ecs"
          }
       },
        portMappings = [
         {
           hostPort = 443,
           protocol = "tcp",
           containerPort = 443
         }
       ],
       cpu = 0,
       environment = [
         {
          name =  "DNS_NAME", 
          value =  "ecs-ss.awsblogs.info"
          }
       ],
       image = "962768705974.dkr.ecr.eu-west-2.amazonaws.com/proxy:latest",
       name = "envoy"
     },

    {
    logConfiguration = {
      logDriver = "awslogs",
      options = {
        awslogs-group = "/ecs/ecs-self-signed",
        awslogs-region = "eu-west-2",
        awslogs-stream-prefix = "ecs"
      }
    },
    cpu = 0,
    image = "962768705974.dkr.ecr.eu-west-2.amazonaws.com/app:latest"
    name = "service"
  }
  ])
}



resource "aws_ecs_service" "bar" {
  name            = "test-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.my_task.arn
  desired_count   = 1
  network_configuration {
    subnets         = [aws_subnet.private_aza.id]
    security_groups = [aws_security_group.lb_sg.id]
    assign_public_ip = false
  }
  launch_type = "FARGATE"

  #   iam_role        = aws_iam_role.foo.arn
  #   depends_on      = [aws_iam_role_policy.foo]

  #   ordered_placement_strategy {
  #     type  = "binpack"
  #     field = "cpu"
  #   }

  # load_balancer {
  #   target_group_arn = aws_lb_target_group.ecs_target_group.arn
  #   container_name   = "fargate-app"
  #   container_port   = 80
  # }

    load_balancer {
    target_group_arn = aws_lb_target_group.ecs_target_group.arn
    container_name   = "envoy"
    container_port   = 443
  }

  #   placement_constraints {
  #     type       = "memberOf"
  #     expression = "attribute:ecs.availability-zone in [us-west-2a, us-west-2b]"
  #   }
}