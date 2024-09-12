# for accessing you need to give permissions using access_key and secrear_key or role need to assign to instance
terraform {
  backend "s3" {
    bucket = "testing-testing-us-east-1"
    key    = "statefile/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = "us-east-1"  # Choose the AWS region you want to deploy to
}

module "vpc" {
    source = "./module/vpc"
vpc_cidr_block_range     = "10.0.0.0/16"
vpc_name                 = "my_vpc"  
cidr_subnet_1            = "10.0.0.0/18"
ag_subnet_1              = "us-east-1a"
map_public_ip_on_launch  = false 
subnet-1_name         = "subnet-1" 
cidr_subnet_2         = "10.0.64.0/18"  
ag_subnet_2           = "us-east-1b"
subnet-2_name         = "subnet-2"
cidr_subnet_3         = "10.0.128.0/18"
ag_subnet_3           = "us-east-1c"
subnet-3_name         = "subnet-3" 
cidr_subnet_4         = "10.0.192.0/18"  
ag_subnet_4           = "us-east-1d"
subnet-4_name         = "subnet-4" 
igw_name              = "my_igw"  
nat_gateway_name      = "my_nat_gateway" 
route_name            = "private_rt"  

  
}
/*
module "eks" {
    source = "./module/eks"

}
#updated
*/