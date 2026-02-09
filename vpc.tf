data "aws_availability_zones" "available" {}

locals {
  azs     = slice(data.aws_availability_zones.available.names, 0, min(3, length(data.aws_availability_zones.available.names)))
  subnets = [for i, az in local.azs : cidrsubnet(var.vpc_cidr, 8, i)]
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "Example idOS"
  }
}

resource "aws_subnet" "this" {
  count = length(local.subnets)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = local.subnets[count.index]
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "Example idOS-${local.azs[count.index]}"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "Example idOS"
  }
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "Example idOS"
  }
}

resource "aws_route" "igw" {
  route_table_id         = aws_route_table.this.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "this" {
  count = length(aws_subnet.this)

  subnet_id      = aws_subnet.this[count.index].id
  route_table_id = aws_route_table.this.id
}
