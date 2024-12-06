resource "aws_vpc" "this" {
  cidr_block = var.cidr_block

  tags = {
    Name = "Example idOS"
  }
}

data "aws_availability_zones" "available" {}
locals {
  vpc_az = data.aws_availability_zones.available.names[0]
}

resource "aws_subnet" "this" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.cidr_block
  availability_zone       = local.vpc_az
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "Example idOS"
  }
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route" "igw" {
    route_table_id = aws_route_table.this.id

    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "this" {
  subnet_id      = aws_subnet.this.id
  route_table_id = aws_route_table.this.id
}
