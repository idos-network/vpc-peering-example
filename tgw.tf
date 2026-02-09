# --- Accept the RAM share (one-time, after idOS adds your account) ---

resource "aws_ram_resource_share_accepter" "tgw" {
  share_arn = var.tgw_ram_share_arn
}

# --- TGW VPC attachment ---

resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = aws_vpc.this.id
  subnet_ids         = aws_subnet.this[*].id

  dns_support                                     = "enable"
  transit_gateway_default_route_table_association = true
  transit_gateway_default_route_table_propagation = true

  tags = {
    Name = "${var.name}-tgw-attachment"
  }

  depends_on = [aws_ram_resource_share_accepter.tgw]
}

# Route all 10.x.x.x (idOS network) traffic via TGW; local VPC is more specific so local traffic stays local
resource "aws_route" "to_tgw" {
  route_table_id         = aws_route_table.this.id
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = var.transit_gateway_id
}
