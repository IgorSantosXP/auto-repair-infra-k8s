resource "aws_security_group" "vpc_link" {
  name   = "${var.project}-vpc-link"
  vpc_id = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }
}

resource "aws_apigatewayv2_vpc_link" "this" {
  name               = "${var.project}-vpc-link"
  subnet_ids         = module.vpc.private_subnets
  security_group_ids = [aws_security_group.vpc_link.id]
}

resource "aws_apigatewayv2_api" "this" {
  name          = "${var.project}-api"
  protocol_type = "HTTP"
}

# One integration per service (each NLB listener forwards to that service's
# NodePort). HTTP APIs pick the most specific route, so the OS Service
# catch-all only receives what Billing and Execution don't own.
resource "aws_apigatewayv2_integration" "service" {
  for_each = local.services

  api_id             = aws_apigatewayv2_api.this.id
  integration_type   = "HTTP_PROXY"
  integration_method = "ANY"
  integration_uri    = aws_lb_listener.service[each.key].arn
  connection_type    = "VPC_LINK"
  connection_id      = aws_apigatewayv2_vpc_link.this.id

  request_parameters = {
    "overwrite:path"                = "$request.path"
    "overwrite:header.X-Request-Id" = "$context.requestId"
  }
}

resource "aws_apigatewayv2_route" "service" {
  for_each = local.service_routes

  api_id    = aws_apigatewayv2_api.this.id
  route_key = each.value.route_key
  target    = "integrations/${aws_apigatewayv2_integration.service[each.value.service].id}"
}

moved {
  from = aws_apigatewayv2_integration.api
  to   = aws_apigatewayv2_integration.service["os"]
}

moved {
  from = aws_apigatewayv2_route.api
  to   = aws_apigatewayv2_route.service["os:ANY /api/{proxy+}"]
}

moved {
  from = aws_apigatewayv2_route.health
  to   = aws_apigatewayv2_route.service["os:GET /up"]
}

resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = "/aws/apigateway/${var.project}"
  retention_in_days = 7
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.this.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format = jsonencode({
      requestId      = "$context.requestId"
      requestTime    = "$context.requestTime"
      httpMethod     = "$context.httpMethod"
      path           = "$context.path"
      status         = "$context.status"
      responseLength = "$context.responseLength"
      latency        = "$context.responseLatency"
      routeKey       = "$context.routeKey"
      integrationErr = "$context.integrationErrorMessage"
    })
  }

  default_route_settings {
    throttling_burst_limit = 100
    throttling_rate_limit  = 50
  }
}
