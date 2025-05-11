data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Amazon Linux 2023 AMI 2023.7.20250428.1 x86_64 HVM kernel-6.1"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "mirror_target" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.traffic_mirror_target_sg.id]

  tags = {
    Name = "ss-cert-verify"
  }
}

resource "aws_security_group" "traffic_mirror_target_sg" {
  name        = "traffic-mirror-target-sg"
  description = "Security group for traffic mirroring target EC2 instance"
  vpc_id      = data.tfe_outputs.ecs_ss_outputs.nonsensitive_values.vpc_id

  egress {
    description = "Allow outbound HTTPS for SSM"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Optionally, allow all egress traffic if preferred
  # egress {
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "-1"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  tags = {
    Name = "traffic-mirror-target-sg"
  }
}

