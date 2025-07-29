#######################################
# Elastic IP for NAT Gateway
#######################################
resource "aws_eip" "nat_eip" {
  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}

#######################################
# NAT Gateway in the first public subnet
#######################################
resource "aws_nat_gateway" "ecs_nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public[0].id # use first public subnet

  tags = {
    Name = "${var.project_name}-natGateway"
  }

  depends_on = [aws_internet_gateway.ecs_gateway]
}