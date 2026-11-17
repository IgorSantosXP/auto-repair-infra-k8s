# Microservices running in the shared EKS cluster. Each one gets its own
# ECR repository, NodePort, NLB listener and API Gateway routes; everything
# else (database, queue, IAM role) lives in the service's own repository.
locals {
  services = {
    os = {
      ecr_repository = "${var.project}-api"
      node_port      = var.api_node_port
      listener_port  = 80
      # Fallback for every /api route not owned by another service.
      routes = ["ANY /api/{proxy+}", "GET /up"]
    }
    billing = {
      ecr_repository = "${var.project}-billing-service"
      node_port      = var.billing_node_port
      listener_port  = 8081
      routes = [
        "ANY /api/v1/budgets",
        "ANY /api/v1/budgets/{proxy+}",
        "ANY /api/v1/payments/{proxy+}",
        "POST /webhooks/mercadopago",
      ]
    }
    execution = {
      ecr_repository = "${var.project}-execution-service"
      node_port      = var.execution_node_port
      listener_port  = 8082
      routes = [
        "ANY /api/v1/parts",
        "ANY /api/v1/parts/{proxy+}",
        "ANY /api/v1/executions",
        "ANY /api/v1/executions/{proxy+}",
      ]
    }
  }

  service_routes = merge([
    for name, svc in local.services : {
      for route in svc.routes : "${name}:${route}" => { service = name, route_key = route }
    }
  ]...)
}
