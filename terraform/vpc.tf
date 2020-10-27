resource "aws_vpc" "awsvpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  tags = {
    Name = "awsvpc"
  }
}

# Subnets
resource "aws_subnet" "public-subnet" {
  vpc_id                  = aws_vpc.awsvpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "eu-east-1a"

  tags = {
    Name = "public-subnet"
  }
}