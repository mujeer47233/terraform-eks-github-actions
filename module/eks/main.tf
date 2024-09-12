# eks iam role for eks cluster
data "aws_subnet" "subnet1" {
  id = "subnet-0decafc3fe3f9b85e"
}

data "aws_subnet" "subnet2" {
  id = "subnet-0bde82f3a520a4929"
}

data "aws_subnet" "subnet3" {
  id = "subnet-08248eff38509f812"
}

data "aws_subnet" "subnet4" {
  id = "subnet-02ecef9c46dd26b85"
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

  vpc_config {
    subnet_ids = [data.aws_subnet.subnet1.id, data.aws_subnet.subnet2.id, data.aws_subnet.subnet3.id, data.aws_subnet.subnet4.id]
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
  cluster_name = var.eks_node_group_cluster_name
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