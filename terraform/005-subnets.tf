#######################################
# locals to place subnets evenly across AZs
#######################################
locals {
  selected_azs = slice(data.aws_availability_zones.available.names, 0, 2)

  # Each AZ gets a different /25 CIDR block for public
  public_subnet_cidrs = [for i in range(length(local.selected_azs)) :
    cidrsubnet(var.cidr_block, 2, i)
  ]

  # Each AZ gets a different /25 CIDR block for private (starts after public)
  private_subnet_cidrs = [for i in range(length(local.selected_azs)) :
    cidrsubnet(var.cidr_block, 2, i + length(local.selected_azs))
  ]
}

#######################################
# ECS public subnets (2 subnets, one per AZ)
#######################################
resource "aws_subnet" "public" {
  count = length(local.selected_azs)

  vpc_id                  = aws_vpc.ecs_vpc.id
  cidr_block              = local.public_subnet_cidrs[count.index]
  availability_zone       = local.selected_azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-publicSubnet-${count.index + 1}"
    AZ   = local.selected_azs[count.index]
    Role = "public"
  }
}

#######################################
# ECS private subnets (2 subnets, one per AZ)
#######################################
resource "aws_subnet" "private" {
  count = length(local.selected_azs)

  vpc_id                  = aws_vpc.ecs_vpc.id
  cidr_block              = local.private_subnet_cidrs[count.index]
  availability_zone       = local.selected_azs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-privateSubnet-${count.index + 1}"
    AZ   = local.selected_azs[count.index]
    Role = "private"
  }
}
