#######################################
# ECS FRONTEND SERVICE (PUBLIC)
#######################################
resource "aws_ecs_service" "quote_frontend_service" {
  name                = "${var.project_name}-frontend-service"
  cluster             = aws_ecs_cluster.ecs_cluster.name
  task_definition     = aws_ecs_task_definition.quoteApp_task.arn
  desired_count       = 1
  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"

  enable_execute_command     = true
  force_new_deployment       = true

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  network_configuration {
    subnets          = [for s in aws_subnet.public : s.id]
    security_groups  = [aws_security_group.ecs_cluster_sg.id]
    assign_public_ip = true
  }

    service_registries {
    registry_arn = aws_service_discovery_service.quote_backend_sd.arn
  }

  propagate_tags = "TASK_DEFINITION"

  tags = {
    Name = "${var.project_name}-frontend-service"
  }

  depends_on = [
    aws_ecs_task_definition.quoteApp_task,
    aws_iam_role.ecs_task_execution_role
  ]
}

#######################################
# ECS BACKEND SERVICE (PRIVATE + SD)
#######################################
resource "aws_ecs_service" "quote_backend_service" {
  name                = "${var.project_name}-backend-service"
  cluster             = aws_ecs_cluster.ecs_cluster.name
  task_definition     = aws_ecs_task_definition.quoteApp_task.arn
  desired_count       = 1
  launch_type         = "FARGATE"
  scheduling_strategy = "REPLICA"

  enable_execute_command     = true
  force_new_deployment       = true

  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  network_configuration {
    subnets          = [for s in aws_subnet.private : s.id]
    security_groups  = [aws_security_group.ecs_cluster_sg.id]
    assign_public_ip = false
  }

  service_registries {
    registry_arn = aws_service_discovery_service.quote_backend_sd.arn
  }

  propagate_tags = "TASK_DEFINITION"

  tags = {
    Name = "${var.project_name}-backend-service"
  }

  depends_on = [
    aws_ecs_task_definition.quoteApp_task,
    aws_iam_role.ecs_task_execution_role
  ]
}
