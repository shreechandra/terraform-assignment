#vpc
resource "aws_vpc" "server1" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "server1-vpc"
  }
}
#internetgateway
resource "aws_internet_gateway" "myInternetGateway" {
  vpc_id = aws_vpc.server1.id
  tags = {
    Name = "myinternetgw"
  }
}
#public subnet
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.server1.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "server1-publicSubnet"
  }
}
#private subnet
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.server1.id
  cidr_block = "10.0.2.0/24"
  tags = {
    Name = "server1-PrivateSubnet"
  }
}
resource "aws_eip" "nat_eip"{
  vpc=true
}
#natgatway
resource "aws_nat_gateway" "myNatGateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id         = aws_subnet.public.id
  tags = {
    Name = "myNatGateway"
  }
}
#route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.server1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myInternetGateway.id
  }
  tags = {
    Name = "publicRouteTable"
  }
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.server1.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.myNatGateway.id
  }
  tags = {
    Name = "privateRouteTable"
  }
}
# routetableassociation
resource "aws_route_table_association" "forPublic" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "forPrivate" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}
#security group
resource "aws_security_group" "public" {
  name = "my-public-sg"
  description = "Public internet access"
  vpc_id = aws_vpc.server1.id
  tags = {
    Name        = "my_sg"
  }
}
#ingress
resource "aws_security_group_rule" "public_in_http" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public.id
}
#egress
resource "aws_security_group_rule" "public_in_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public.id
}


