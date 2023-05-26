resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block #"10.0.0.0/16"
  tags = {
    Name = "${terraform.workspace}-vpc" # dev-vpc
  }
}

resource "aws_subnet" "az1_public_subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.subnets[0].cidr_block
  availability_zone = var.availability_zones[0]
  tags = {
    Name = "${terraform.workspace}-${var.subnets[0].type}-subnet"
  }
}

resource "aws_subnet" "az1_private_subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.subnets[1].cidr_block
  availability_zone = var.availability_zones[0]
  tags = {
    Name = "${terraform.workspace}-${var.subnets[1].type}-subnet"
  }
}

resource "aws_subnet" "az2_public_subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.subnets[2].cidr_block
  availability_zone = var.availability_zones[1]
  tags = {
    Name = "${terraform.workspace}-${var.subnets[2].type}-subnet"
  }
}

resource "aws_subnet" "az2_private_subnet" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = var.subnets[3].cidr_block
  availability_zone = var.availability_zones[1]
  tags = {
    Name = "${terraform.workspace}-${var.subnets[3].type}-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${terraform.workspace}-igw"
  }
}

resource "aws_default_route_table" "rtbl" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${terraform.workspace}-default-route-table"
  }
}

resource "aws_eip" "elastic_ip" {
  vpc = true
    tags = {
    Name = "${terraform.workspace}-eip"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.elastic_ip.id
  subnet_id     = aws_subnet.az1_public_subnet.id
  depends_on = [aws_internet_gateway.igw]
  tags = {
    Name = "${terraform.workspace}-nat-gateway"
  }
}

resource "aws_route_table" "private_rtbl" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${terraform.workspace}-private-route-table"
  }
}

resource "aws_route" "private_nat_gateway_route" {
  route_table_id            = aws_route_table.private_rtbl.id
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id            = aws_nat_gateway.nat_gateway.id
}

resource "aws_route_table_association" "az1_private_subnet_rtbl_association" {
  subnet_id      = aws_subnet.az1_private_subnet.id
  route_table_id = aws_route_table.private_rtbl.id
}

resource "aws_route_table_association" "az2_private_subnet_rtbl_association" {
  subnet_id      = aws_subnet.az2_private_subnet.id
  route_table_id = aws_route_table.private_rtbl.id
}