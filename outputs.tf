output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}

output "vpc_cidr" {
  value = var.vpc_cidr
}

output "cluster_name" {
  value = module.eks.cluster_name
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "node_security_group_id" {
  value = module.eks.node_security_group_id
}

output "ecr_repository_url" {
  value = aws_ecr_repository.service["os"].repository_url
}

output "ecr_repository_urls" {
  value = { for name, repo in aws_ecr_repository.service : name => repo.repository_url }
}

output "node_ports" {
  value = { for name, svc in local.services : name => svc.node_port }
}

output "events_topic_arns" {
  description = "SNS topic of the saga message bus, per environment"
  value       = { for env, topic in aws_sns_topic.events : env => topic.arn }
}

output "api_gateway_url" {
  value = aws_apigatewayv2_stage.default.invoke_url
}

output "api_gateway_id" {
  value = aws_apigatewayv2_api.this.id
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions.arn
}

output "api_node_port" {
  value = var.api_node_port
}

output "api_gateway_execution_arn" {
  value = aws_apigatewayv2_api.this.execution_arn
}

output "datadog_saga_dashboard_url" {
  value = local.datadog_enabled ? "https://app.${var.datadog_site}/dashboard/${datadog_dashboard.saga[0].id}" : "Datadog desativado"
}

output "datadog_dashboard_url" {
  value = local.datadog_enabled ? "https://app.${var.datadog_site}/dashboard/${datadog_dashboard.operations[0].id}" : "Datadog desativado — informe datadog_api_key e datadog_app_key"
}
