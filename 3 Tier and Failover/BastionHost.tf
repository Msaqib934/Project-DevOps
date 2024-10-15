resource "aws_security_group" "bastionhost" {
  name        = "bastionhost"
  description = "Dev VPC Default Security Group"
  vpc_id      = aws_vpc.vpc-dev.id

  ingress {
    description = "Allow Port RDP"
    from_port   = 3389
    to_port     = 3389
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
    Name = "bastionhost"
  }
}

# Create Keypair for Bastion Host

resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = "myKey"       # Create a "myKey" to AWS!!
  public_key = tls_private_key.pk.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename = "${aws_key_pair.kp.key_name}.pem"
  content = tls_private_key.pk.private_key_pem
}

#Create EC2 for Bastion Host

resource "aws_instance" "Bastion" {
  ami           = "ami-0be0e902919675894" # Replace with your desired AMI ID
  instance_type = "t2.micro"             # Replace with your desired instance type
  key_name      = aws_key_pair.kp.id   # Replace with your EC2 key pair name
  subnet_id     = aws_subnet.vpc-dev-public-subnet-1.id # Replace with your desired subnet ID

  tags = {
    Name = "BastionHost"
  }
}

