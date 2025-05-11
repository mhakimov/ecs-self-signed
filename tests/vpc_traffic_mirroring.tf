resource "aws_ec2_traffic_mirror_filter" "filter" {
  description      = "traffic mirror filter - terraform example"
  network_services = ["amazon-dns"]
}

resource "aws_ec2_traffic_mirror_target" "target" {
  network_interface_id = aws_instance.mirror_target.primary_network_interface_id
}

resource "aws_ec2_traffic_mirror_session" "session" {
  network_interface_id     = var.source_eni_id
  session_number           = 1
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.filter.id
  traffic_mirror_target_id = aws_ec2_traffic_mirror_target.target.id
}
