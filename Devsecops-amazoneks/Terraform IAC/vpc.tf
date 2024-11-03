# Resources Block
# Resource-1: Create VPC
resource "aws_vpc" "vpc-dev" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" = "vpc-dev"
  }
}

# Resource-2: Create Subnets
resource "aws_subnet" "vpc-dev-public-subnet-1" {
  vpc_id                  = aws_vpc.vpc-dev.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    "Name" = "public-subnet-1"
    "Value" = "vpc-dev-public-1"
  }
}

resource "aws_subnet" "vpc-dev-public-subnet-2" {
  vpc_id                  = aws_vpc.vpc-dev.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "vpc-dev-private-subnet-1" {
  vpc_id                  = aws_vpc.vpc-dev.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false
}

resource "aws_subnet" "vpc-dev-private-subnet-2" {
  vpc_id                  = aws_vpc.vpc-dev.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false
}

# Resource-3: Internet Gateway
resource "aws_internet_gateway" "vpc-dev-igw" {
  vpc_id = aws_vpc.vpc-dev.id
}

# Resource-3: NatGateway
resource "aws_eip" "nat1" {
  instance = null # You can set this to an EC2 instance ID if you want to associate the EIP with an instance, or leave it as null.
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat1.id
  subnet_id     = aws_subnet.vpc-dev-public-subnet-1.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.vpc-dev-igw]
}

# Resource-4: Create Route Table
resource "aws_route_table" "vpc-dev-public-route-table" {
  vpc_id = aws_vpc.vpc-dev.id
}

resource "aws_route_table" "vpc-dev-private-route-table" {
  vpc_id = aws_vpc.vpc-dev.id
}

# Resource-5: Create Route in Route Table for Internet Access
resource "aws_route" "vpc-dev-public-route" {
  route_table_id         = aws_route_table.vpc-dev-public-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.vpc-dev-igw.id
}

resource "aws_route" "vpc-dev-private-route" {
  route_table_id         = aws_route_table.vpc-dev-private-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.nat.id
}

# Resource-6: Associate the Route Table with the Subnet
resource "aws_route_table_association" "vpc-dev-public-route-table-associate1" {
  route_table_id = aws_route_table.vpc-dev-public-route-table.id
  subnet_id      = aws_subnet.vpc-dev-public-subnet-1.id
}

resource "aws_route_table_association" "vpc-dev-public-route-table-associate2" {
  route_table_id = aws_route_table.vpc-dev-public-route-table.id
  subnet_id      = aws_subnet.vpc-dev-public-subnet-2.id
}

resource "aws_route_table_association" "vpc-dev-private-route-table-associate1" {
  route_table_id = aws_route_table.vpc-dev-private-route-table.id
  subnet_id      = aws_subnet.vpc-dev-private-subnet-1.id
}

resource "aws_route_table_association" "vpc-dev-private-route-table-associate2" {
  route_table_id = aws_route_table.vpc-dev-private-route-table.id
  subnet_id      = aws_subnet.vpc-dev-private-subnet-2.id
}