resource "datadog_dashboard" "operations" {
  count = local.datadog_enabled ? 1 : 0

  title       = "Auto Repair — Operação"
  description = "Volume de ordens de serviço, tempo por status, erros de integração e saúde do cluster."
  layout_type = "ordered"
  reflow_type = "auto"

  widget {
    timeseries_definition {
      title = "Volume diário de ordens de serviço"

      request {
        q            = "sum:auto_repair.service_order.created{*}.as_count().rollup(sum, 86400)"
        display_type = "bars"

        style {
          palette = "cool"
        }
      }
    }
  }

  widget {
    query_value_definition {
      title     = "Ordens abertas nas últimas 24h"
      autoscale = true
      precision = 0

      request {
        q          = "sum:auto_repair.service_order.created{*}.as_count()"
        aggregator = "sum"
      }
    }
  }

  widget {
    timeseries_definition {
      title = "Tempo médio em cada status (segundos)"

      request {
        q            = "avg:auto_repair.service_order.status_duration{*} by {status}"
        display_type = "line"
      }
    }
  }

  widget {
    toplist_definition {
      title = "Tempo médio por status — Diagnóstico, Execução, Finalização"

      request {
        q = "top(avg:auto_repair.service_order.status_duration{status IN (in_diagnosis, in_execution, finished)} by {status}, 10, 'mean', 'desc')"
      }
    }
  }

  widget {
    timeseries_definition {
      title = "Transições de status"

      request {
        q            = "sum:auto_repair.service_order.status_changed{*} by {to}.as_count()"
        display_type = "bars"
      }
    }
  }

  widget {
    timeseries_definition {
      title = "Falhas no processamento de ordens de serviço"

      request {
        q            = "sum:auto_repair.service_order.failed{*} by {stage,reason}.as_count()"
        display_type = "bars"

        style {
          palette = "warm"
        }
      }
    }
  }

  widget {
    timeseries_definition {
      title = "Erros e falhas nas integrações"

      request {
        q            = "sum:auto_repair.integration.error{*} by {integration}.as_count()"
        display_type = "bars"

        style {
          palette = "warm"
        }
      }
    }
  }

  widget {
    timeseries_definition {
      title = "Latência das APIs (p50, p95, p99)"

      request {
        q            = "p50:trace.rack.request{service:auto-repair-api}"
        display_type = "line"
      }

      request {
        q            = "p95:trace.rack.request{service:auto-repair-api}"
        display_type = "line"
      }

      request {
        q            = "p99:trace.rack.request{service:auto-repair-api}"
        display_type = "line"
      }
    }
  }

  widget {
    timeseries_definition {
      title = "Requisições por segundo e taxa de erro"

      request {
        q            = "sum:trace.rack.request.hits{service:auto-repair-api}.as_rate()"
        display_type = "line"
      }

      request {
        q            = "sum:trace.rack.request.errors{service:auto-repair-api}.as_rate()"
        display_type = "bars"

        style {
          palette = "warm"
        }
      }
    }
  }

  widget {
    timeseries_definition {
      title = "CPU dos pods da API"

      request {
        q            = "avg:kubernetes.cpu.usage.total{kube_deployment:api} by {pod_name}"
        display_type = "line"
      }
    }
  }

  widget {
    timeseries_definition {
      title = "Memória dos pods da API"

      request {
        q            = "avg:kubernetes.memory.usage{kube_deployment:api} by {pod_name}"
        display_type = "line"
      }
    }
  }

  widget {
    timeseries_definition {
      title = "Réplicas em execução (escalonamento do HPA)"

      request {
        q            = "max:kubernetes_state.deployment.replicas_available{kube_deployment:api}"
        display_type = "line"
      }
    }
  }

  widget {
    timeseries_definition {
      title = "Lambda de autenticação — invocações e erros"

      request {
        q            = "sum:aws.lambda.invocations{functionname:auto-repair-auth}.as_count()"
        display_type = "bars"
      }

      request {
        q            = "sum:aws.lambda.errors{functionname:auto-repair-auth}.as_count()"
        display_type = "bars"

        style {
          palette = "warm"
        }
      }
    }
  }
}
