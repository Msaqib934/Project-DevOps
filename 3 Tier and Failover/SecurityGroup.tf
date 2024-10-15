# Resource-1: Create Security For ELB-1
resource "aws_security_group" "ELB1" {
  name        = "ELB-1"
  description = "Dev VPC Default Security Group"
  vpc_id      = aws_vpc.vpc-dev.id

  ingress {
    description = "Allow Port 80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all IP and Ports Outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "SaqibELB1"
  }
}

# Resource-2: Create Security For AutoScaling-1
resource "aws_security_group" "ASG1" {
  name        = "ASG-1"
  description = "Dev VPC Default Security Group"
  vpc_id      = aws_vpc.vpc-dev.id

  tags = {
    Name = "SaqibASG1"
  }
}


resource "aws_security_group_rule" "allow_group1_to_group2" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "-1"
  source_security_group_id = aws_security_group.ELB1.id
  security_group_id        = aws_security_group.ASG1.id
}