resource "datadog_dashboard" "saga" {
  count = local.datadog_enabled ? 1 : 0

  title       = "Auto Repair — Saga e Microsserviços"
  description = "Saga orquestrada da OS (OS, Billing e Execution): sagas iniciadas, concluídas e compensadas, tráfego no barramento SNS/SQS, pagamentos, estoque e latência de cada serviço."
  layout_type = "ordered"
  reflow_type = "auto"

  widget {
    query_value_definition {
      title     = "Sagas iniciadas (período)"
      autoscale = true
      precision = 0

      request {
        q          = "sum:auto_repair.saga.started{*}.as_count()"
        aggregator = "sum"
      }
    }
  }

  widget {
    query_value_definition {
      title     = "Sagas concluídas (período)"
      autoscale = true
      precision = 0

      request {
        q          = "sum:auto_repair.saga.completed{*}.as_count()"
        aggregator = "sum"
      }
    }
  }

  widget {
    query_value_definition {
      title     = "Compensações executadas (período)"
      autoscale = true
      precision = 0

      request {
        q          = "sum:auto_repair.saga.compensated{*}.as_count()"
        aggregator = "sum"
      }
    }
  }

  widget {
    query_value_definition {
      title     = "Compensações com falha (período)"
      autoscale = true
      precision = 0

      request {
        q          = "sum:auto_repair.saga.compensation_failed{*}.as_count()"
        aggregator = "sum"

        conditional_formats {
          comparator = ">"
          value      = 0
          palette    = "white_on_red"
        }
      }
    }
  }

  widget {
    timeseries_definition {
      title = "Desfecho das sagas"

      request {
        q            = "sum:auto_repair.saga.completed{*}.as_count()"
        display_type = "bars"
      }

      request {
        q            = "sum:auto_repair.saga.failed{*} by {reason}.as_count()"
        display_type = "bars"

        style {
          palette = "warm"
        }
      }

      request {
        q            = "sum:auto_repair.saga.compensated{*} by {reason}.as_count()"
        display_type = "bars"

        style {
          palette = "orange"
        }
      }
    }
  }

  widget {
    timeseries_definition {
      title = "Duração da saga até a conclusão (p50 / p95, segundos)"

      request {
        q            = "p50:auto_repair.saga.duration{*}"
        display_type = "line"
      }

      request {
        q            = "p95:auto_repair.saga.duration{*}"
        display_type = "line"
      }
    }
  }

  widget {
    toplist_definition {
      title = "Passos da saga por mensagem"

      request {
        q = "top(sum:auto_repair.saga.step{*} by {type,direction}.as_count(), 20, 'sum', 'desc')"
      }
    }
  }

  widget {
    timeseries_definition {
      title = "Mensagens publicadas e consumidas por serviço"

      request {
        q            = "sum:auto_repair.messaging.published{*} by {service}.as_count()"
        display_type = "bars"
      }

      request {
        q            = "sum:auto_repair.messaging.consumed{*} by {service}.as_count()"
        display_type = "line"
      }
    }
  }

  widget {
    timeseries_definition {
      title = "Falhas no processamento de mensagens (vão para retry / DLQ)"

      request {
        q            = "sum:auto_repair.messaging.failed{*} by {service,type}.as_count()"
        display_type = "bars"

        style {
          palette = "warm"
        }
      }
    }
  }

  widget {
    timeseries_definition {
      title = "Billing — orçamentos e pagamentos por status"

      request {
        q            = "sum:auto_repair.billing.budget{*} by {status}.as_count()"
        display_type = "bars"
      }

      request {
        q            = "sum:auto_repair.billing.payment{*} by {status}.as_count()"
        display_type = "bars"

        style {
          palette = "purple"
        }
      }
    }
  }

  widget {
    timeseries_definition {
      title = "Execution — reservas de estoque"

      request {
        q            = "sum:auto_repair.execution.stock_reservation{*} by {result}.as_count()"
        display_type = "bars"
      }
    }
  }

  widget {
    timeseries_definition {
      title = "Erros de integração (Mercado Pago, catálogo de peças, e-mail)"

      request {
        q            = "sum:auto_repair.integration.error{*} by {service,integration}.as_count()"
        display_type = "bars"

        style {
          palette = "warm"
        }
      }
    }
  }

  widget {
    timeseries_definition {
      title = "Latência p95 das APIs por serviço"

      request {
        q            = "p95:trace.rack.request{env:prod} by {service}"
        display_type = "line"
      }
    }
  }

  widget {
    timeseries_definition {
      title = "Taxa de erro HTTP por serviço"

      request {
        q            = "sum:trace.rack.request.errors{env:prod} by {service}.as_rate()"
        display_type = "line"

        style {
          palette = "warm"
        }
      }
    }
  }

  widget {
    timeseries_definition {
      title = "Réplicas disponíveis por deployment"

      request {
        q            = "max:kubernetes_state.deployment.replicas_available{kube_namespace:auto-repair*} by {kube_namespace,kube_deployment}"
        display_type = "line"
      }
    }
  }
}
