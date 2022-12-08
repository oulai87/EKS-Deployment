provider "aws" {
  region = var.region
}
module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  version                         = "17.20.0"
  cluster_name                    = local.cluster_name
  cluster_version                 = "1.21"
  subnets                         = var.subnet_ids
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  manage_cluster_iam_resources    = true
  manage_worker_iam_resources     = true
  manage_aws_auth                 = true
  map_users                       = var.map_users
  tags = {
    Environment = "test"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }

  vpc_id = var.existing_vpc_id
  node_groups_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = 20
  }

  node_groups = {
    example = {
      desired_capacity = 2
      max_capacity     = 2
      min_capacity     = 2

      instance_types = ["t2.small"]
      capacity_type  = "SPOT"
      k8s_labels = {
        Environment = "test"
        GithubRepo  = "terraform-aws-eks"
        GithubOrg   = "terraform-aws-modules"
      }
      update_config = {
        max_unavailable_percentage = 50 # or set `max_unavailable`
      }
    }
  }
}
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
locals {
  cluster_name = var.cluster_name
}
variable "existing_vpc_id" {
  type = string
}
variable "cluster_name" {
  type = string
}
variable "subnet_ids" {
  type = list(string)
}
variable "region" {
  type = string
}
variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}
