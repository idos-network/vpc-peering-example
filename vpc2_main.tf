provider "aws" {
  region = "eu-west-1"
  alias  = "vpc2"
}

# Data source for VPC2
data "aws_ami" "vpc2_amazon_linux_2023" {
  provider    = aws.vpc2
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

# VPC 2
resource "aws_vpc" "vpc2" {
  provider   = aws.vpc2
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "VPC2"
  }
}

resource "aws_subnet" "subnet2" {
  provider                = aws.vpc2
  vpc_id                  = aws_vpc.vpc2.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "eu-west-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Subnet2"
  }
}

resource "aws_internet_gateway" "example_igw_vpc2" {
  provider = aws.vpc2
  vpc_id   = aws_vpc.vpc2.id
  tags = {
    Name = "example_igw_vpc2"
  }
}

resource "aws_route_table" "example_route_table_vpc2" {
  provider = aws.vpc2
  vpc_id   = aws_vpc.vpc2.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example_igw_vpc2.id
  }

  tags = {
    Name = "example_route_table_vpc2"
  }
}

resource "aws_route_table_association" "example_route_table_assoc_vpc2" {
  provider      = aws.vpc2
  subnet_id     = aws_subnet.subnet2.id
  route_table_id = aws_route_table.example_route_table_vpc2.id
}

resource "aws_security_group" "vpc2_sg" {
  provider = aws.vpc2
  vpc_id   = aws_vpc.vpc2.id

  # Allow SSH from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP (port 8080) from VPC1 CIDR block
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # VPC1 CIDR block
  }

  # Allow custom application traffic (port 8484) from VPC1 CIDR block
  ingress {
    from_port   = 8484
    to_port     = 8484
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # VPC1 CIDR block
  }

  # Allow ICMP traffic from anywhere
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "VPC2 Security Group"
  }
}

resource "tls_private_key" "example_vpc2" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key_vpc2_" {
  provider   = aws.vpc2
  key_name   = "VPC2_Key_"
  public_key = file("public_key.pem")
}

resource "aws_instance" "vpc2_instance" {
  provider                = aws.vpc2
  ami                    = data.aws_ami.vpc2_amazon_linux_2023.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.generated_key_vpc2_.key_name
  subnet_id              = aws_subnet.subnet2.id
  vpc_security_group_ids = [aws_security_group.vpc2_sg.id]

  tags = {
    Name = "VPC2 Instance"
  }
}

# Accept the VPC peering connection
resource "aws_vpc_peering_connection_accepter" "vpc2_accepts_peering" {
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc1_to_vpc2.id
  auto_accept               = true
  tags = {
    Name = "VPC2 Accepts Peering"
  }
}

# Add route in VPC2's route table for traffic to VPC1
resource "aws_route" "vpc2_to_vpc1_route" {
  route_table_id         = aws_route_table.example_route_table_vpc2.id
  destination_cidr_block = "10.0.0.0/16" # Alex CIDR block
  vpc_peering_connection_id = "pcx-0909ddb4ed1909ad6"
}

output "vpc2_instance_private_ip" {
  value = aws_instance.vpc2_instance.private_ip
}

output "vpc2_instance_public_ip" {
  value = aws_instance.vpc2_instance.public_ip
}

output "vpc2_key_to_ec2" {
  value     = tls_private_key.example_vpc2.private_key_openssh
  sensitive = true
}
