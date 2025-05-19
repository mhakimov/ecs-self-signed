resource "aws_lb" "onyx" {
  name               = "alb-onyx"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.public_aza.id, aws_subnet.public_azb.id]
}

# resource "aws_lb_listener" "alb_listener_http" {
#   load_balancer_arn = aws_lb.onyx.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     target_group_arn = aws_lb_target_group.ecs_target_group.arn
#     type             = "forward"
#   }
# }

resource "aws_lb_listener" "alb_listener_https" {
  load_balancer_arn = aws_lb.onyx.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  certificate_arn = aws_acm_certificate.cert.arn

  default_action {
    target_group_arn = aws_lb_target_group.ecs_target_group.arn
    type             = "forward"
  }
}


resource "aws_lb_target_group" "ecs_target_group" {
  name        = "precious-target-group"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = aws_vpc.ecs_ss_vpc.id
  target_type = "ip"

  health_check {
    # path = "/"
    path     = "/service"
    protocol = "HTTP"
  }
}
