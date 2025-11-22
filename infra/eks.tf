module "eks" {
  source                                   = "terraform-aws-modules/eks/aws"
  version                                  = "21.8.0"
  name                                     = "${var.project}-eks"
  kubernetes_version                       = "1.34"
  vpc_id                                   = module.vpc.vpc_id
  subnet_ids                               = module.vpc.private_subnets
  control_plane_subnet_ids                 = module.vpc.private_subnets
  endpoint_public_access                   = true
  enable_cluster_creator_admin_permissions = true
  endpoint_public_access_cidrs             = ["XX.XX.XX.XX/XX"] #Change this to your endpoint. Ideally for prod create bastion. This is suitable only for demo.
  enabled_log_types                        = []
  eks_managed_node_groups = {
    compute = {
      ami_type      = "BOTTLEROCKET_x86_64"
      instance_type = ["t3.small"]
      min_size      = 3
      max_size      = 3
      desired_size  = 3
    }
  }
  addons = {
    coredns = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }

  }
  tags = local.common_tags
}
