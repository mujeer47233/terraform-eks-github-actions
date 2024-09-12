# eks iam role for eks 
provider "aws" {
  region = "us-east-1"  # Choose the AWS region you want to deploy to
}
data "aws_subnet" "subnet1" {
  id = var.subnet1
}

data "aws_subnet" "subnet2" {
  id = var.subnet2
}

data "aws_subnet" "subnet3" {
  id = var.subnet3
}

data "aws_subnet" "subnet4" {
  id = var.subnet4
}

resource "aws_iam_role" "eks_cluster" {
  name = var.cluster_role_name

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

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role      = aws_iam_role.eks_cluster.name

}

resource "aws_iam_role_policy_attachment" "eks-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks_cluster.name
}
# EKS cluster creation

resource "aws_eks_cluster" "dxlab" {
  name = var.cluster_name 
  role_arn = aws_iam_role.eks_cluster.arn
  version = var.eks_master_version

  vpc_config {
    subnet_ids = [data.aws_subnet.subnet1.id, data.aws_subnet.subnet2.id, data.aws_subnet.subnet3.id, data.aws_subnet.subnet4.id]
    endpoint_private_access = true
    endpoint_public_access  = false
  }
  depends_on = [
    aws_iam_role_policy_attachment.eks-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks-AmazonEKSVPCResourceController,
  ]
}


resource "aws_iam_role" "nodes" {
  name = var.iam_role_node  
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

resource "aws_iam_role_policy_attachment" "Amazon_S3_ReadOnlyAccess" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "Amazon_EKS_ServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.nodes.name
}


# EKS Node group

resource "aws_eks_node_group" "private-nodes" {
  cluster_name = aws_eks_cluster.dxlab.name
  node_group_name = var.cluster_node_group_name
  node_role_arn = aws_iam_role.nodes.arn
  remote_access {
  ec2_ssh_key = "eks"
  }

  subnet_ids = [data.aws_subnet.subnet1.id, data.aws_subnet.subnet2.id]
  instance_types = var.instance_type

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size 

  }
  update_config {
    max_unavailable = var.max_unavailable
  }
  depends_on = [
    aws_iam_role_policy_attachment.nodes-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nodes-AmazonEC2ContainerRegistyReadOnly,
    aws_iam_role_policy_attachment.nodes-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.Amazon_S3_ReadOnlyAccess,
    aws_iam_role_policy_attachment.Amazon_EKS_ServicePolicy,	
  ]
}