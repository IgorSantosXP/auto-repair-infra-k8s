variable "project" {
  type    = string
  default = "auto-repair"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "kubernetes_version" {
  type    = string
  default = "1.31"
}

variable "node_instance_type" {
  type    = string
  default = "t3.medium"
}

variable "node_desired_size" {
  type    = number
  default = 2
}

variable "node_max_size" {
  type    = number
  default = 4
}

variable "api_node_port" {
  type    = number
  default = 30080
}

variable "billing_node_port" {
  type    = number
  default = 30081
}

variable "execution_node_port" {
  type    = number
  default = 30082
}

variable "environments" {
  description = "Environments that get their own event topic (one namespace per environment in the cluster)"
  type        = list(string)
  default     = ["prod", "homolog"]
}

variable "github_owner" {
  type    = string
  default = "IgorSantosXP"
}

variable "github_repositories" {
  type = list(string)
  default = [
    "auto-repair-api",
    "auto-repair-billing-service",
    "auto-repair-execution-service",
    "auto-repair-infra-k8s",
    "auto-repair-infra-database",
    "auto-repair-auth-lambda"
  ]
}

variable "datadog_api_key" {
  type      = string
  default   = ""
  sensitive = true
}

variable "datadog_site" {
  type    = string
  default = "datadoghq.com"
}

variable "datadog_app_key" {
  type      = string
  default   = ""
  sensitive = true
}

variable "datadog_alert_email" {
  type    = string
  default = ""
}
