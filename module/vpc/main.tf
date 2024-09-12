
resource "aws_vpc" "my_vpc" {

  cidr_block = "var.vpc_cidr_block_range"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "var.vpc_name"
  }
}
resource "aws_subnet" "subnet_1" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.cidr_subnet_1
  availability_zone = var.ag_subnet_1
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = {
    Name = var.subnet-1_name
  }
}

resource "aws_subnet" "subnet_2" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.cidr_subnet_2
  availability_zone = var.ag_subnet_2  # Choose an appropriate availability zone 
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = {
    Name = var.subnet-2_name  
  }
}


resource "aws_subnet" "subnet_3" {
  vpc_id     = aws_vpc.my_vpc.id  
  cidr_block = var.cidr_subnet_3 
  availability_zone =  var.ag_subnet_3 # Choose an appropriate availability zone  
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = {
    Name = var.subnet-3_name
  }
}
resource "aws_subnet" "subnet_4" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.cidr_subnet_4
  availability_zone =  var.ag_subnet_4 # Choose an appropriate availability zone  
  map_public_ip_on_launch = favar.map_public_ip_on_launchlse

  tags = {
    Name = var.subnet-4_name
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = var.igw_name
  }
}

resource "aws_nat_gateway" "my_nat" {
  allocation_id = aws_eip.my_eip.id
  subnet_id     = aws_subnet.subnet_1.id  # Place NAT Gateway in one of the subnets

  tags = {
    Name = var.nat_gateway_name
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
    Name = var.route_name
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

output "subnet1" {
  value = aws_subnet.subnet_1.id
  
}
output "subnet2" {
  value = aws_subnet.subnet_2.id
  
}
output "subnet3" {
  value = aws_subnet.subnet_3.id
  
}
output "subnet4" {
  value = aws_subnet.subnet_4.id
  
}