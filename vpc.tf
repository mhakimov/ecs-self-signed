resource "aws_vpc" "ecs_ss_vpc" {
  cidr_block = "172.16.0.0/16"
   tags = {
    Name = "ecs-ss-vpc"
  }
}

resource "aws_internet_gateway" "ecs_ss_gw" {
  vpc_id = aws_vpc.ecs_ss_vpc.id

  tags = {
    Name = "ecs-ss-igw"
  }
}

resource "aws_route_table" "ecs_ss_route_table" {
  vpc_id = aws_vpc.ecs_ss_vpc.id
   tags = {
    Name = "ecs-ss-rt"
  }
}

resource "aws_route" "ecs_ss_route" {
  route_table_id         = aws_route_table.ecs_ss_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  #  gateway_id             = aws_nat_gateway.nat_gw.id
    gateway_id             = aws_internet_gateway.ecs_ss_gw.id
}


#SUBNETS

  #public

resource "aws_subnet" "public_aza" {
  vpc_id            = aws_vpc.ecs_ss_vpc.id
  cidr_block        = "172.16.0.0/18"
  availability_zone = "eu-west-2a"
   tags = {
    Name = "ecs-ss-public-subnet-a"
  }
}

resource "aws_subnet" "public_azb" {
  vpc_id            = aws_vpc.ecs_ss_vpc.id
  cidr_block        = "172.16.64.0/18"
  availability_zone = "eu-west-2b"
   tags = {
    Name = "ecs-ss-public-subnet-b"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.ecs_ss_vpc.id
   tags = {
    Name = "ecs-ss-public-subnet-rt"
  }
}

resource "aws_route" "to_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ecs_ss_gw.id
}

resource "aws_route_table_association" "public_subnet_association_a" {
  subnet_id      = aws_subnet.public_aza.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_subnet_association_b" {
  subnet_id      = aws_subnet.public_azb.id
  route_table_id = aws_route_table.public.id
}

  #private
resource "aws_subnet" "private_aza" {
  vpc_id            = aws_vpc.ecs_ss_vpc.id
  cidr_block        = "172.16.128.0/18"
  availability_zone = "eu-west-2a"
   tags = {
    Name = "ecs-ss-private-aza"
  }
}

resource "aws_subnet" "private_azb" {
  vpc_id            = aws_vpc.ecs_ss_vpc.id
  cidr_block        = "172.16.192.0/18"
  availability_zone = "eu-west-2b"
   tags = {
    Name = "ecs-ss-private-azb"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.ecs_ss_vpc.id
   tags = {
    Name = "ecs-ss-private-rt"
  }
}

resource "aws_route" "to_nat_gw" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id             = aws_nat_gateway.nat_gw.id
}

resource "aws_route_table_association" "private_subnet_association_a" {
  subnet_id      = aws_subnet.private_aza.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_subnet_association_b" {
  subnet_id      = aws_subnet.private_azb.id
  route_table_id = aws_route_table.private.id
}

# NAT GW
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_gw_eip.id
  subnet_id     = aws_subnet.public_azb.id

  tags = {
    Name = "ecs-ss gw NAT"
  }

  depends_on = [aws_internet_gateway.ecs_ss_gw]
}

resource "aws_eip" "nat_gw_eip" {
  domain   = "vpc"
}




