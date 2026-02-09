# Allow SSH from internet; Kwil RPC and P2P from entire idOS network (all TGW participants use 10.x.x.x)
resource "aws_security_group" "this" {
  vpc_id = aws_vpc.this.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kwil RPC from idOS network (TGW participants)"
    from_port   = 8484
    to_port     = 8484
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    description = "Kwil P2P from idOS network (TGW participants)"
    from_port   = 6600
    to_port     = 6600
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  ingress {
    description = "ICMP from idOS network (for connectivity checks between nodes)"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Example idOS node"
  }
}
