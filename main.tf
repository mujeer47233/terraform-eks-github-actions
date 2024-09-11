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
  
}

module "eks" {
    source = "./module/eks"

}
#updated

