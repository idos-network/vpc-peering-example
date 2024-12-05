resource "null_resource" "wait_for_vpc_propagation" {
  depends_on = [aws_vpc.vpc1, aws_vpc.vpc2]

  provisioner "local-exec" {
    command = "sleep 30" # Wait for 30 seconds to allow AWS to propagate the VPC ID
  }
}

resource "aws_vpc_peering_connection" "vpc1_to_vpc2" {
  vpc_id      = aws_vpc.vpc1.id
  peer_vpc_id = aws_vpc.vpc2.id
  auto_accept = true

  tags = {
    Name = "VPC1-to-VPC2"
  }

  depends_on = [null_resource.wait_for_vpc_propagation]
}