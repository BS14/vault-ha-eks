module "eks" {
  source                               = "terraform-aws-modules/eks/aws"
  version                              = "21.8.0"
  cluster_name                         = "${var.project}-eks"
  cluster_version                      = "1.34"
  vpc_id                               = module.vpc.vpc_id
  subnet_ids                           = module.vpc.private_subnets
  control_plane_subnet_ids             = module.vpc.private_subnets
  cluster_endpoint_public_access       = true
  enable_cluster_creator_admin_permissions = true
  cluster_endpoint_public_access_cidrs = ["X.X.X.X.X/32"]
  cluster_enabled_log_types = []
  eks_managed_node_groups = {
    compute = {
      ami_type      = "BOTTLEROCKET_x86_64"
      instance_type = ["t3.small"]
      min_size      = 3
      max_size      = 3
    }
  }
  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}

  }
  tags = local.common_tags
  depends_on = ["module.vpc"]
}
