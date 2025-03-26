variable "name" {
  description = "cluster name"
}

variable "public_subnet_1" {
  description = "ID of the first public subnet"
}

variable "public_subnet_2" {
  description = "ID of the second public subnet"
}

variable "private_subnet_1" {
  description = "The CIDR block for the private subnet 1"
}

variable "private_subnet_2" {
  description = "The CIDR block for the private subnet 2"
}