module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.31"

  cluster_name    = "${var.project}-eks"
  cluster_version = var.kubernetes_version

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.public_subnets
  control_plane_subnet_ids = concat(module.vpc.public_subnets, module.vpc.private_subnets)

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    coredns        = {}
    kube-proxy     = {}
    vpc-cni        = {}
    metrics-server = {}
  }

  eks_managed_node_groups = {
    default = {
      instance_types = [var.node_instance_type]
      min_size       = var.node_desired_size
      max_size       = var.node_max_size
      desired_size   = var.node_desired_size

      subnet_ids = module.vpc.public_subnets
    }
  }

  node_security_group_additional_rules = {
    metrics_server = {
      description                   = "Cluster API to metrics-server secure port"
      protocol                      = "tcp"
      from_port                     = 10251
      to_port                       = 10251
      type                          = "ingress"
      source_cluster_security_group = true
    }

    nlb_health_check = {
      description = "NLB health check and traffic to the API NodePort"
      protocol    = "tcp"
      from_port   = var.api_node_port
      to_port     = var.api_node_port
      type        = "ingress"
      cidr_blocks = [var.vpc_cidr]
    }
  }
}
