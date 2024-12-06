resource "aws_vpc_peering_connection" "connection" {
  vpc_id = aws_vpc.this.id

  peer_owner_id = var.remote_account_id
  peer_vpc_id   = var.remote_vpc_id
  peer_region   = var.remote_peer_region

  tags = {
    Name = "${var.name} to ${var.remote_peer_name}"
  }
}

resource "aws_route" "to_remote_vpc" {
  route_table_id            = aws_route_table.this.id
  destination_cidr_block    = var.remote_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.connection.id
}

output "vpc_peering_connection_id" {
  value = aws_vpc_peering_connection.connection.id
}
