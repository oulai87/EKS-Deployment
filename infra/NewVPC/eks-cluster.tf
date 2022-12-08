module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  cluster_name                    = local.cluster_name
  cluster_version                 = "1.23"
  subnet_ids                      = module.vpc.private_subnets
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  tags = {
    Environment = "test"
    GithubRepo  = "K8s-EKS-QuickStart"
  }
  cluster_addons = {
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
    kube-proxy = {}
    vpc-cni = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  manage_aws_auth_configmap = true

  vpc_id = module.vpc.vpc_id

  cluster_security_group_additional_rules = {
    egress_nodes_ephemeral_ports_tcp = {
      description                = "To node 1025-65535"
      protocol                   = "tcp"
      from_port                  = 1025
      to_port                    = 65535
      type                       = "egress"
      source_node_security_group = true
    }
  }

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Node all egress"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  eks_managed_node_group_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = 20
  }

  eks_managed_node_groups = {
    default = {
      desired_capacity         = 2
      max_capacity             = 2
      min_capacity             = 2
      create_iam_role          = true
      iam_role_name            = "eks-managed-node-group-default"
      iam_role_use_name_prefix = false
      iam_role_description     = "EKS managed node group default role"
      iam_role_tags = {
        Purpose = "Protector of the kubelet"
      }
      iam_role_additional_policies = [
        "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      ]
      create_security_group          = true
      security_group_name            = "eks-managed-node-group-default"
      security_group_use_name_prefix = false
      vpc_security_group_ids         = [aws_security_group.all_worker_mgmt.id]
      subnet_ids                     = module.vpc.private_subnets
      instance_types                 = ["t2.small"]
      capacity_type                  = "SPOT"
      k8s_labels = {
        Environment = "test"
        GithubRepo  = "K8s-EKS-QuickStart"
      }
      update_config = {
        max_unavailable_percentage = 50 # or set `max_unavailable`
      }
    }
  }

  aws_auth_users = var.map_users

}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_caller_identity" "current" {}

variable "map_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))

  default = []
}