# Output for VPC ID
output "vpc_id" {
  value       = aws_vpc.vpc-dev.id
  description = "The ID of the VPC"
}

# Outputs for public subnet IDs
output "vpc_dev_public_subnet_1" {
  value       = aws_subnet.vpc-dev-public-subnet-1.id
  description = "The ID of public subnet 1 in the VPC"
}

output "vpc_dev_public_subnet_2" {
  value       = aws_subnet.vpc-dev-public-subnet-2.id
  description = "The ID of public subnet 2 in the VPC"
}

# Outputs for private subnet IDs
output "vpc_dev_private_subnet_1" {
  value       = aws_subnet.vpc-dev-private-subnet-1.id
  description = "The ID of private subnet 1 in the VPC"
}

output "vpc_dev_private_subnet_2" {
  value       = aws_subnet.vpc-dev-private-subnet-2.id
  description = "The ID of private subnet 2 in the VPC"
}

# Output for Internet Gateway ID
output "internet_gateway_id" {
  value       = aws_internet_gateway.vpc-dev-igw.id
  description = "The ID of the Internet Gateway attached to the VPC"
}

# Output for NAT Gateway ID
output "nat_gateway_id" {
  value       = aws_nat_gateway.nat.id
  description = "The ID of the NAT Gateway"
}

# Outputs for route table IDs
output "public_route_table_id" {
  value       = aws_route_table.vpc-dev-public-route-table.id
  description = "The ID of the public route table in the VPC"
}

output "private_route_table_id" {
  value       = aws_route_table.vpc-dev-private-route-table.id
  description = "The ID of the private route table in the VPC"
}
