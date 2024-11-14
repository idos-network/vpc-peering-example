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

# Add route in VPC1's route table for traffic to VPC2
resource "aws_route" "vpc1_to_vpc2_route" {
  route_table_id         = aws_route_table.example_route_table.id
  destination_cidr_block = aws_vpc.vpc2.cidr_block # Automatically fetch VPC2's CIDR block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc1_to_vpc2.id
}

# Add route in VPC2's route table for traffic to VPC1
resource "aws_route" "vpc2_to_vpc1_route" {
  route_table_id         = aws_route_table.example_route_table_vpc2.id
  destination_cidr_block = aws_vpc.vpc1.cidr_block # Automatically fetch VPC1's CIDR block
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc1_to_vpc2.id
}
