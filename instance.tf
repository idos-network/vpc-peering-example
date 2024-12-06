data "aws_ami" "vpc2_amazon_linux_2023" {
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

resource "aws_instance" "this" {
  ami                    = data.aws_ami.vpc2_amazon_linux_2023.id
  instance_type          = "t3.large"
  key_name               = aws_key_pair.this.key_name
  subnet_id              = aws_subnet.this.id
  iam_instance_profile   = aws_iam_instance_profile.this.id
  vpc_security_group_ids = [aws_security_group.this.id]

  tags = {
    Name = "Example idOS"
  }

  lifecycle {
    ignore_changes = [
      # We don't care that new AMIs are released, only to use the
      #latest when launching new instances.
      ami,
    ]
  }
}

resource "aws_key_pair" "this" {
  key_name   = "Example idOS"
  public_key = file(var.ssh_keypair_pub_path)
}

output "instance_public_ip" {
  value = aws_instance.this.public_ip
}

output "instance_private_ip" {
  value = aws_instance.this.private_ip
}
