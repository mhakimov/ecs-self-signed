output "vpc_id" {
  value = aws_vpc.ecs_ss_vpc.id
}
output "private_subnet_aza_id" {
  value = aws_subnet.private_aza.id
}
