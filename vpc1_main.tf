provider "aws" {
  region = "eu-west-1"
  alias  = "vpc1"
}

# Data source for VPC1
data "aws_ami" "vpc1_amazon_linux_2023" {
  provider    = aws.vpc1
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

# VPC 1
resource "aws_vpc" "vpc1" {
  provider   = aws.vpc1
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "VPC1"
  }
}

resource "aws_subnet" "subnet1" {
  provider                = aws.vpc1
  vpc_id                  = aws_vpc.vpc1.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Subnet1"
  }
}

resource "aws_internet_gateway" "example_igw" {
  provider = aws.vpc1
  vpc_id   = aws_vpc.vpc1.id
  tags = {
    Name = "example_igw"
  }
}

resource "aws_route_table" "example_route_table" {
  provider = aws.vpc1
  vpc_id   = aws_vpc.vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example_igw.id
  }

  tags = {
    Name = "example_route_table"
  }
}

resource "aws_route_table_association" "example_route_table_assoc" {
  provider      = aws.vpc1
  subnet_id     = aws_subnet.subnet1.id
  route_table_id = aws_route_table.example_route_table.id
}

resource "aws_security_group" "vpc1_sg" {
  provider = aws.vpc1
  vpc_id   = aws_vpc.vpc1.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "VPC1 Security Group"
  }
}

resource "tls_private_key" "example_vpc1" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key_vpc1_" {
  provider   = aws.vpc1
  key_name   = "VPC1_Key_"
  public_key = file("public_key.pem")
}

resource "aws_instance" "vpc1_instance" {
  provider                = aws.vpc1
  ami                    = data.aws_ami.vpc1_amazon_linux_2023.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.generated_key_vpc1_.key_name
  subnet_id              = aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.vpc1_sg.id]

  tags = {
    Name = "VPC1 Instance"
  }
}

output "vpc1_instance_private_ip" {
  value = aws_instance.vpc1_instance.private_ip
}

output "vpc1_instance_public_ip" {
  value = aws_instance.vpc1_instance.public_ip
}

output "vpc1_key_to_ec2" {
  value     = tls_private_key.example_vpc1.private_key_openssh
  sensitive = true
}
