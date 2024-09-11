terraform {
  required_version = "~> 1.9.0"
  required_providers {
    aws = {
      version = ">= 5.99.0"
      source = "hashicorp/aws"
    }
  }
  backend "s3" {
    bucket = "testing-testing-us-east-1"
    key    = "statefile"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"  # Choose the AWS region you want to deploy to
}

resource "aws_vpc" "my_vpc" {

  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "my_vpc"
  }
}

resource "aws_subnet" "subnet_1" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.0.0/18"
  availability_zone = "us-east-1a"  # Choose an appropriate availability zone
  map_public_ip_on_launch = false

  tags = {
    Name = "subnet-1"
  }
}

resource "aws_subnet" "subnet_2" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.64.0/18"
  availability_zone = "us-east-1b"  # Choose an appropriate availability zone
  map_public_ip_on_launch = false

  tags = {
    Name = "subnet-2"
  }
}

resource "aws_subnet" "subnet_3" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.128.0/18"
  availability_zone = "us-east-1c"  # Choose an appropriate availability zone
  map_public_ip_on_launch = false

  tags = {
    Name = "subnet-3"
  }
}
resource "aws_subnet" "subnet_4" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.192.0/18"
  availability_zone = "us-east-1d"  # Choose an appropriate availability zone
  map_public_ip_on_launch = false

  tags = {
    Name = "subnet-4"
  }
}
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my_igw"
  }
}

resource "aws_nat_gateway" "my_nat" {
  allocation_id = aws_eip.my_eip.id
  subnet_id     = aws_subnet.subnet_1.id  # Place NAT Gateway in one of the subnets

  tags = {
    Name = "my_nat_gateway"
  }
}

resource "aws_eip" "my_eip" {
  domain   = "vpc"
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my_nat.id
  }

  tags = {
    Name = "private_rt"
  }
}

resource "aws_route_table_association" "subnet_1_assoc" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "subnet_2_assoc" {
  subnet_id      = aws_subnet.subnet_2.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "subnet_3_assoc" {
  subnet_id      = aws_subnet.subnet_3.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "subnet_4_assoc" {
  subnet_id      = aws_subnet.subnet_4.id
  route_table_id = aws_route_table.private_rt.id
}