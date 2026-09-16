provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project   = var.project
      ManagedBy = "terraform"
      Repo      = "auto-repair-infra-k8s"
    }
  }
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

provider "datadog" {
  api_key  = var.datadog_api_key == "" ? null : var.datadog_api_key
  app_key  = var.datadog_app_key == "" ? null : var.datadog_app_key
  api_url  = "https://api.${var.datadog_site}/"
  validate = var.datadog_api_key != "" && var.datadog_app_key != ""
}

locals {
  datadog_enabled = nonsensitive(var.datadog_api_key != "" && var.datadog_app_key != "")
  alert_target    = var.datadog_alert_email == "" ? "" : "@${var.datadog_alert_email}"
}
