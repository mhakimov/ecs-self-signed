locals {
  ssh_port     = 22
  http_port    = 80
  https_port   = 443
  any_port     = 0
  all_ips      = ["0.0.0.0/0"]
  tcp_protocol = "tcp"
}

resource "aws_lb" "onyx" {
  name               = "alb-onyx"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.subnet_aza.id, aws_subnet.subnet_azb.id]
}

resource "aws_lb_listener" "alb_listener_http" {
  load_balancer_arn = aws_lb.onyx.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.ecs_target_group.arn
    type             = "forward"
  }
}

resource "aws_lb_listener" "alb_listener_https" {
  load_balancer_arn = aws_lb.onyx.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  certificate_arn = aws_acm_certificate.webapp_cert.arn

  default_action {
    target_group_arn = aws_lb_target_group.ecs_target_group.arn
    type             = "forward"
  }
}

resource "aws_acm_certificate" "webapp_cert" {
  domain_name       = var.domain_name
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "https_record" {
  allow_overwrite = true
  name            = tolist(aws_acm_certificate.webapp_cert.domain_validation_options)[0].resource_record_name
  records         = [tolist(aws_acm_certificate.webapp_cert.domain_validation_options)[0].resource_record_value]
  type            = tolist(aws_acm_certificate.webapp_cert.domain_validation_options)[0].resource_record_type
  zone_id         = var.hosted_zone_id
  ttl             = 60
}

resource "aws_acm_certificate_validation" "webapp_cert_validation" {
  certificate_arn         = aws_acm_certificate.webapp_cert.arn
  validation_record_fqdns = [aws_route53_record.https_record.fqdn]
}

resource "aws_lb_target_group" "ecs_target_group" {
  name        = "precious-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.ecs_ss_vpc.id
  target_type = "ip"

  health_check {
    path = "/"
  }
}