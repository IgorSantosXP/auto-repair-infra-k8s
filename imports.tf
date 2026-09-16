import {
  to = module.eks.aws_eks_access_entry.this["operator"]
  id = "auto-repair-eks:arn:aws:iam::814623398856:user/auto-repair-deploy"
}

import {
  to = module.eks.aws_eks_access_policy_association.this["operator_admin"]
  id = "auto-repair-eks#arn:aws:iam::814623398856:user/auto-repair-deploy#arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
}
