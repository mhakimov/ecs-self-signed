resource "aws_ec2_traffic_mirror_target" "target" {
  network_interface_id = aws_instance.mirror_target.primary_network_interface_id
}

resource "aws_ec2_traffic_mirror_session" "session" {
  network_interface_id     = var.source_eni_id
  session_number           = 1
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.filter.id
  traffic_mirror_target_id = aws_ec2_traffic_mirror_target.target.id
}

resource "aws_ec2_traffic_mirror_filter" "filter" {
  description      = "traffic mirror filter - terraform example"
  network_services = ["amazon-dns"]
}

resource "aws_ec2_traffic_mirror_filter_rule" "inbound_http" {
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.filter.id
  rule_number              = 100
  rule_action              = "accept"
  traffic_direction        = "ingress"
  protocol                 = 6 # TCP
  destination_port_range {
    from_port = 80
    to_port   = 80
  }
  source_port_range {
    from_port = 0
    to_port   = 65535
  }
  source_cidr_block      = "0.0.0.0/0"
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_ec2_traffic_mirror_filter_rule" "inbound_https" {
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.filter.id
  rule_number              = 101
  rule_action              = "accept"
  traffic_direction        = "ingress"
  protocol                 = 6 # TCP
  destination_port_range {
    from_port = 443
    to_port   = 443
  }
  source_port_range {
    from_port = 0
    to_port   = 65535
  }
  source_cidr_block      = "0.0.0.0/0"
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_ec2_traffic_mirror_filter_rule" "outbound_http" {
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.filter.id
  rule_number              = 102
  rule_action              = "accept"
  traffic_direction        = "egress"
  protocol                 = 6 # TCP
  source_port_range {
    from_port = 80
    to_port   = 80
  }
  destination_port_range {
    from_port = 0
    to_port   = 65535
  }
  source_cidr_block      = "0.0.0.0/0"
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_ec2_traffic_mirror_filter_rule" "outbound_https" {
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.filter.id
  rule_number              = 103
  rule_action              = "accept"
  traffic_direction        = "egress"
  protocol                 = 6 # TCP
  source_port_range {
    from_port = 443
    to_port   = 443
  }
  destination_port_range {
    from_port = 0
    to_port   = 65535
  }
  source_cidr_block      = "0.0.0.0/0"
  destination_cidr_block = "0.0.0.0/0"
}
