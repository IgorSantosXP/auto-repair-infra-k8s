resource "aws_ecr_repository" "service" {
  for_each = local.services

  name                 = each.value.ecr_repository
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "service" {
  for_each = local.services

  repository = aws_ecr_repository.service[each.key].name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep the last 10 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
      action = { type = "expire" }
    }]
  })
}

moved {
  from = aws_ecr_repository.api
  to   = aws_ecr_repository.service["os"]
}

moved {
  from = aws_ecr_lifecycle_policy.api
  to   = aws_ecr_lifecycle_policy.service["os"]
}
