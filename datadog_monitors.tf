resource "datadog_monitor" "service_order_failures" {
  count = local.datadog_enabled ? 1 : 0

  name    = "[Auto Repair] Falhas no processamento de ordens de serviço"
  type    = "metric alert"
  message = <<-EOT
    A aplicação registrou falhas ao criar ou transicionar ordens de serviço nos
    últimos 10 minutos. As tags `stage` e `reason` indicam onde falhou —
    criação, transição de status ou reserva de estoque.

    Cruzar com o Log Explorer (`service:auto-repair-api status:error`) e seguir o
    `request_id` até o trace no APM.
    ${local.alert_target}
  EOT

  query = "sum(last_10m):sum:auto_repair.service_order.failed{*}.as_count() > 5"

  monitor_thresholds {
    critical = 5
    warning  = 1
  }

  notify_no_data    = false
  renotify_interval = 30
  tags              = ["project:auto-repair", "team:soat"]
}

resource "datadog_monitor" "integration_errors" {
  count = local.datadog_enabled ? 1 : 0

  name    = "[Auto Repair] Erros de integração"
  type    = "metric alert"
  message = <<-EOT
    A aplicação registrou falhas de integração — reserva de estoque ou envio de
    e-mail de status. Conferir o widget "Erros e falhas nas integrações" no
    dashboard de Operação.
    ${local.alert_target}
  EOT

  query = "sum(last_10m):sum:auto_repair.integration.error{*}.as_count() > 10"

  monitor_thresholds {
    critical = 10
    warning  = 3
  }

  notify_no_data    = false
  renotify_interval = 60
  tags              = ["project:auto-repair", "team:soat"]
}

resource "datadog_monitor" "api_uptime" {
  count = local.datadog_enabled ? 1 : 0

  name    = "[Auto Repair] Pods da API indisponíveis"
  type    = "metric alert"
  message = <<-EOT
    O número de réplicas disponíveis do Deployment `api` caiu abaixo do mínimo
    configurado no HPA.
    ${local.alert_target}
  EOT

  query = "min(last_5m):min:kubernetes_state.deployment.replicas_available{kube_deployment:api} < 1"

  monitor_thresholds {
    critical = 1
  }

  notify_no_data    = true
  no_data_timeframe = 10
  renotify_interval = 30
  tags              = ["project:auto-repair", "team:soat"]
}

resource "datadog_monitor" "api_latency" {
  count = local.datadog_enabled ? 1 : 0

  name    = "[Auto Repair] Latência da API acima do esperado"
  type    = "metric alert"
  message = <<-EOT
    O p95 de latência das requisições passou de 2 segundos nos últimos 10
    minutos. Verificar se o HPA escalou e se o banco é o gargalo.
    ${local.alert_target}
  EOT

  query = "avg(last_10m):p95:trace.rack.request{service:auto-repair-api} > 2"

  monitor_thresholds {
    critical = 2
    warning  = 1
  }

  notify_no_data    = false
  renotify_interval = 60
  tags              = ["project:auto-repair", "team:soat"]
}

resource "datadog_monitor" "auth_lambda_errors" {
  count = local.datadog_enabled ? 1 : 0

  name    = "[Auto Repair] Erros na função de autenticação"
  type    = "metric alert"
  message = <<-EOT
    A Lambda de autenticação por CPF está retornando erro. Conferir o grupo de
    logs `/aws/lambda/auto-repair-auth` — a causa mais provável é
    indisponibilidade do RDS.
    ${local.alert_target}
  EOT

  query = "sum(last_10m):sum:aws.lambda.errors{functionname:auto-repair-auth}.as_count() > 5"

  monitor_thresholds {
    critical = 5
    warning  = 1
  }

  notify_no_data    = false
  renotify_interval = 60
  tags              = ["project:auto-repair", "team:soat"]
}

resource "datadog_monitor" "saga_compensation_failed" {
  count = local.datadog_enabled ? 1 : 0

  name    = "[Auto Repair] Compensação da saga falhou"
  type    = "metric alert"
  message = <<-EOT
    Uma saga de ordem de serviço não conseguiu ser compensada (ex.: o estorno no
    Mercado Pago falhou). A OS foi cancelada, mas o cliente pode ter sido cobrado:
    é preciso intervenção manual.

    Abrir `GET /api/v1/service_orders/:id/saga` para ver os passos e buscar o
    `saga_id` no Log Explorer (`@saga_id:<id>`) para seguir a saga nos 3 serviços.
    ${local.alert_target}
  EOT

  query = "sum(last_5m):sum:auto_repair.saga.compensation_failed{*}.as_count() > 0"

  monitor_thresholds {
    critical = 0
  }

  notify_no_data    = false
  renotify_interval = 60
  tags              = ["project:auto-repair", "team:soat", "component:saga"]
}

resource "datadog_monitor" "saga_compensations" {
  count = local.datadog_enabled ? 1 : 0

  name    = "[Auto Repair] Volume alto de compensações da saga"
  type    = "metric alert"
  message = <<-EOT
    Muitas sagas estão sendo compensadas (falta de estoque ou pagamento recusado).
    A tag `reason` indica a causa. Conferir o dashboard "Saga e Microsserviços".
    ${local.alert_target}
  EOT

  query = "sum(last_30m):sum:auto_repair.saga.compensating{*}.as_count() > 5"

  monitor_thresholds {
    critical = 5
    warning  = 2
  }

  notify_no_data    = false
  renotify_interval = 60
  tags              = ["project:auto-repair", "team:soat", "component:saga"]
}

resource "datadog_monitor" "messaging_failures" {
  count = local.datadog_enabled ? 1 : 0

  name    = "[Auto Repair] Falhas no consumo de mensagens"
  type    = "metric alert"
  message = <<-EOT
    Um worker está falhando ao processar mensagens do barramento. As mensagens
    voltam para a fila e, após 3 tentativas, vão para a DLQ do serviço
    (`auto-repair-<env>-<service>-dlq`). As tags `service` e `type` indicam onde.
    ${local.alert_target}
  EOT

  query = "sum(last_10m):sum:auto_repair.messaging.failed{*} by {service}.as_count() > 5"

  monitor_thresholds {
    critical = 5
    warning  = 1
  }

  notify_no_data    = false
  renotify_interval = 30
  tags              = ["project:auto-repair", "team:soat", "component:messaging"]
}
