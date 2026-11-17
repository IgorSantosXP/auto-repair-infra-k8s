resource "aws_lb" "api" {
  name               = "${var.project}-nlb"
  internal           = true
  load_balancer_type = "network"
  subnets            = module.vpc.private_subnets
}

resource "aws_lb_target_group" "service" {
  for_each = local.services

  name        = "${var.project}-${each.key}-tg"
  port        = each.value.node_port
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = module.vpc.vpc_id

  health_check {
    protocol            = "HTTP"
    path                = "/up"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 10
  }

  deregistration_delay = 30
}

resource "aws_lb_listener" "service" {
  for_each = local.services

  load_balancer_arn = aws_lb.api.arn
  port              = each.value.listener_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.service[each.key].arn
  }
}

resource "aws_autoscaling_attachment" "service" {
  for_each = local.services

  autoscaling_group_name = module.eks.eks_managed_node_groups["default"].node_group_autoscaling_group_names[0]
  lb_target_group_arn    = aws_lb_target_group.service[each.key].arn
}

moved {
  from = aws_lb_listener.api
  to   = aws_lb_listener.service["os"]
}

moved {
  from = aws_autoscaling_attachment.api
  to   = aws_autoscaling_attachment.service["os"]
}
