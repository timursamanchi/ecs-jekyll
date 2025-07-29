#######################################
# Public Subnet Route Table with default route 
# to Internet Gateway + Association
#######################################
resource "aws_route_table" "ecs_public_rt" {
  vpc_id = aws_vpc.ecs_vpc.id

  tags = {
    Name = "${var.project_name}-publicRT"
  }
}

resource "aws_route" "ecs_public_internet" {
  route_table_id         = aws_route_table.ecs_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ecs_gateway.id
}

resource "aws_route_table_association" "ecs_public_assoc" {
  count          = length(local.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.ecs_public_rt.id
}

#######################################
# Private Subnet Route Table with default route 
# to NAT Gateway + Association
#######################################
resource "aws_route_table" "ecs_private_rt" {
  vpc_id = aws_vpc.ecs_vpc.id

  tags = {
    Name = "${var.project_name}-privateRT"
  }
}

resource "aws_route" "ecs_private_nat_route" {
  route_table_id         = aws_route_table.ecs_private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ecs_nat.id
}

resource "aws_route_table_association" "ecs_private_assoc" {
  count          = length(local.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.ecs_private_rt.id
}
