variable "vpc_cidr" {}
variable "vpc_name" {}
variable "ap_availability_zone" {}
variable "cidr_public_subnet" {}
variable "cidr_private_subnet" {}

  
output "aws-vpc-id" {
  value = aws_vpc.aws-vpc-restapi.id
}

output "aws_vpc_public_subnets" {
  value = aws_subnet.aws_vpc_public_subnets.*.id
}

output "public_subnet_cidr_block" {
  value = aws_subnet.aws_vpc_public_subnets.*.cidr_block
}

output "aws_vpc_private_subnets" {
 value = aws_subnet.aws_vpc_private_subnets.*.id
}

output "private_subnet_cidr_block" {
  value = aws_subnet.aws_vpc_private_subnets.*.cidr_block
}

# Setup VPC
resource "aws_vpc" "aws-vpc-restapi" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = var.vpc_name
  }
}


# Setup public subnet
resource "aws_subnet" "aws_vpc_public_subnets" {
  count             = length(var.cidr_public_subnet)
  vpc_id            = aws_vpc.aws-vpc-restapi.id
  cidr_block        = element(var.cidr_public_subnet, count.index)
  availability_zone = element(var.ap_availability_zone, count.index)

  tags = {
    Name = "Public-subnet-${count.index + 1}"
  }
}

# Setup private subnet
resource "aws_subnet" "aws_vpc_private_subnets" {
  count             = length(var.cidr_private_subnet)
  vpc_id            = aws_vpc.aws-vpc-restapi.id
  cidr_block        = element(var.cidr_private_subnet, count.index)
  availability_zone = element(var.ap_availability_zone, count.index)

  tags = {
    Name = "Private-subnet-${count.index + 1}"
  }
}

# Setup Internet Gateway
resource "aws_internet_gateway" "aws_vpc_restapi_internet_gateway" {
  vpc_id = aws_vpc.aws-vpc-restapi.id
  tags = {
    Name = "igw"
  }
}


# Public Route Table
resource "aws_route_table" "aws_vpc_restapi_public_route_table" {
  vpc_id = aws_vpc.aws-vpc-restapi.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.aws_vpc_restapi_internet_gateway.id
  }
  tags = {
    Name = "Public-rt"
  }
}

# Public Route Table and Public Subnet Association
resource "aws_route_table_association" "aws_vpc_restapi_public_rt_subnet_association" {
  count          = length(aws_subnet.aws_vpc_public_subnets)
  subnet_id      = aws_subnet.aws_vpc_public_subnets[count.index].id
  route_table_id = aws_route_table.aws_vpc_restapi_public_route_table.id
}

# Private Route Table
resource "aws_route_table" "aws_vpc_private_subnets" {
  vpc_id = aws_vpc.aws-vpc-restapi.id
  # depends_on = [aws_nat_gateway.nat_gateway]
  tags = {
    Name = "Private-rt"
  }
}

# Private Route Table and private Subnet Association
resource "aws_route_table_association" "aws_vpc_restapi_private_rt_subnet_association" {
  count          = length(aws_subnet.aws_vpc_private_subnets)
  subnet_id      = aws_subnet.aws_vpc_private_subnets[count.index].id
  route_table_id = aws_route_table.aws_vpc_private_subnets.id
}


resource "aws_eip" "nat" {
  tags = {
    Name = "Nat gateway"
  }
}

resource "aws_nat_gateway" "nat" {
 allocation_id = aws_eip.nat.id
 subnet_id     = aws_subnet.aws_vpc_public_subnets[0].id
}

resource "aws_route_table" "private" {
 vpc_id = aws_vpc.aws-vpc-restapi.id

 route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
 }
}

resource "aws_route_table_association" "private" {
 count          = length(aws_subnet.aws_vpc_private_subnets)
 subnet_id      = aws_subnet.aws_vpc_private_subnets[count.index].id
 route_table_id = aws_route_table.private.id
}
