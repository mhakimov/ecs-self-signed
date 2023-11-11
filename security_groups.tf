resource "aws_security_group" "lb_sg" {
  name_prefix = "alb_sg_"
  vpc_id      = aws_vpc.ecs_ss_vpc.id
  description = "security group for alb"

  ingress {
    from_port   = local.http_port
    to_port     = local.http_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
  }

  ingress {
    from_port   = local.https_port
    to_port     = local.https_port
    protocol    = local.tcp_protocol
    cidr_blocks = local.all_ips
  }

  egress {
    from_port   = local.any_port
    to_port     = local.any_port
    protocol    = "-1"
    cidr_blocks = local.all_ips
  }

  tags = {
    Name = "alb-security-group"
  }
}

resource "aws_security_group" "ecs_security_group" {
  name_prefix = "ecs-sec-group"
  description = "security group for ecs"
  vpc_id      = aws_vpc.ecs_ss_vpc.id

  #   ingress {
  #     from_port   = 22
  #     to_port     = 22
  #     protocol    = local.tcp_protocol
  #     cidr_blocks = local.all_ips
  #   }

  ingress {
    from_port = local.http_port
    to_port   = local.http_port
    protocol  = local.tcp_protocol
    # cidr_blocks = local.all_ips
    security_groups = [aws_security_group.lb_sg.id]
  }

  ingress {
    from_port       = local.https_port
    to_port         = local.https_port
    protocol        = local.tcp_protocol
    security_groups = [aws_security_group.lb_sg.id]
  }

  egress {
    from_port   = local.any_port
    to_port     = local.any_port
    protocol    = "-1"
    cidr_blocks = local.all_ips
  }

  tags = {
    Name = "ecs-security-group"
    Made = "terraform"
  }
}