# for accessing you need to give permissions using access_key and secrear_key or role need to assign to instance
terraform {
  required_version = "~> 1.9.0"
  required_providers {
    aws = {
      version = ">= 5.66.0"
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
  region = "us-east-1"
}
#-------------------------------------
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw"
  }
}
#----------------------------------------
resource "aws_subnet" "private-us-east-1a" {
  vpc_id      = aws_vpc.main.id
  cidr_block  = "10.0.0.0/19"
  availability_zone = "us-east-1a"

  tags = {
    "Name"                             = "private-us-east-1a"
        "kubernetes.io/role/interbal-elb"  = "1"
        "kubernetes.io/cluster/demo"       = "owned"

  }
}

resource "aws_subnet" "private-us-east-1b" {
  vpc_id      = aws_vpc.main.id
  cidr_block  = "10.0.32.0/19"
  availability_zone = "us-east-1b"

  tags = {
    "Name"                             = "private-us-east-1b"
        "kubernetes.io/role/interbal-elb"  = "1"
        "kubernetes.io/cluster/demo"       = "owned"

  }
}

resource "aws_subnet" "public-us-east-1a" {
  vpc_id                   = aws_vpc.main.id
  cidr_block               = "10.0.64.0/19"
  availability_zone        = "us-east-1a"
  map_public_ip_on_launch  = true

  tags = {
    "Name"                             = "public-us-east-1a"
        "kubernetes.io/role/interbal-elb"  = "1"
        "kubernetes.io/cluster/demo"       = "owned"

  }
}

resource "aws_subnet" "public-us-east-1b" {
  vpc_id                   = aws_vpc.main.id
  cidr_block               = "10.0.96.0/19"
  availability_zone        = "us-east-1b"
  map_public_ip_on_launch  = true

  tags = {
    "Name"                             = "public-us-east-1b"
        "kubernetes.io/role/interbal-elb"  = "1"
        "kubernetes.io/cluster/demo"       = "owned"

  }
}

#----------------net gateway ------------------------------

resource "aws_eip" "nat" {
  vpc =true

  tags = {
    Name = "nat"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public-us-east-1a.id

  tags = {
    Name = "nat"
  }
  depends_on = [aws_internet_gateway.igw]
}
#----------------- private route ---------------------
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
       cidr_block       = "0.0.0.0/0"
       nat_gateway_id   = aws_nat_gateway.nat.id
    }
  tags = {
    Name = "private"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
           cidr_block = "0.0.0.0/0"
           gateway_id = aws_internet_gateway.igw.id
     }

  tags = {
    Name = "public"
  }
}

# subnets are adding to

resource "aws_route_table_association" "private-us-east-1a" {
  route_table_id = aws_route_table.private.id
  subnet_id = aws_subnet.private-us-east-1a.id
}

resource "aws_route_table_association" "private-us-east-1b" {
  subnet_id = aws_subnet.private-us-east-1b.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public-us-east-1a" {
  subnet_id = aws_subnet.public-us-east-1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-us-east-1b" {
  subnet_id = aws_subnet.public-us-east-1a.id
  route_table_id = aws_route_table.public.id
}
# eks iam role for eks cluster

resource "aws_iam_role" "demo" {
  name = "eks-cluster-demo"

  assume_role_policy = jsonencode({
    Version =  "2012-10-17"
    Statement =  [
      {
        Action = "sts:AssumeRole"
        Effect =  "Allow"
        Principal = {
          Service =  "eks.amazonaws.com"
          }
         },
      ]

  })
}

resource "aws_iam_role_policy_attachment" "demo-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.demo.name

}

# EKS cluster creation

resource "aws_eks_cluster" "demo" {
  name = "demo"
  role_arn = aws_iam_role.demo.arn

  vpc_config {
    subnet_ids = [
          aws_subnet.private-us-east-1a.id,
          aws_subnet.private-us-east-1b.id,
          aws_subnet.public-us-east-1a.id,
          aws_subnet.public-us-east-1b.id
        ]
  }
  depends_on = [
    aws_iam_role_policy_attachment.demo-AmazonEKSClusterPolicy,
  ]
}

  #

resource "aws_iam_role" "nodes" {
  name = "eks-node-group-nodes"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    "Statement": [
      {
           Action  = "sts:AssumeRole"
           Effect  = "Allow"
           Principal = {
             "Service": "ec2.amazonaws.com"
            }
          },
       ]
     })
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role = aws_iam_role.nodes.name
}


resource "aws_iam_role_policy_attachment" "nodes-AmazonEC2ContainerRegistyReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}


# EKS Node group

resource "aws_eks_node_group" "private-nodes" {
  cluster_name = aws_eks_cluster.demo.name
  node_group_name = "private-nodes"
  node_role_arn = aws_iam_role.nodes.arn

  subnet_ids = [
    aws_subnet.private-us-east-1a.id,
    aws_subnet.private-us-east-1b.id
  ]
  instance_types = ["t2.micro"]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1

  }
  update_config {
    max_unavailable = 2
  }
  labels = {
    role = "general"
  }
}