#######################################
# Task Definition: quote-backend and quote-frontend
#######################################
resource "aws_ecs_task_definition" "quoteApp_task" {
  family                   = "${var.project_name}-taskDef"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "512"
  memory                   = "1024"

  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    jsondecode(file("${path.module}/../json/quote-backend.json")),
    jsondecode(file("${path.module}/../json/quote-frontend.json"))
  ])

  depends_on = [
    aws_cloudwatch_log_group.quote_backend,
    aws_cloudwatch_log_group.quote_frontend
  ]
}
