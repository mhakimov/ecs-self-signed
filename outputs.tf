output "vpc_id" {
  value = aws_vpc.ecs_ss_vpc.id
}
output "private_subnet_aza_id" {
  value = aws_subnet.private_aza.id
}

output "ecs_task_sg_id" {
  value = aws_security_group.ecs_security_group.id
}
