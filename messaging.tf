# Message bus shared by the microservices: one SNS topic per environment.
# Each service subscribes its own SQS queue (with a filter policy on the
# `destination` attribute) from its own repository, so the platform only
# owns the topic.
resource "aws_sns_topic" "events" {
  for_each = toset(var.environments)

  name = "${var.project}-${each.key}-events"
}
