#######################################
# Create Namespace, ECS Cluster 
# service discovery and tag it
#######################################

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.project_name}-ecsCluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "${var.project_name}-ecsCluster"
  }
}
#######################################
# service discovery and tag it
#######################################
resource "aws_service_discovery_private_dns_namespace" "quote_namespace" {
  name        = "internal.local"
  vpc         = aws_vpc.ecs_vpc.id
  description = "Quote service namespace"

  tags = {
    Name = "${var.project_name}-namespace"
  }
}

resource "aws_service_discovery_service" "quote_backend_sd" {
  name = "quote-backend"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.quote_namespace.id
    dns_records {
      type = "A"
      ttl  = 30
    }
    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }

  tags = {
    Name = "${var.project_name}-backend-sd"
  }
}

resource "aws_service_discovery_service" "quote_frontend_sd" {
  name = "quote-frontend"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.quote_namespace.id
    dns_records {
      type = "A"
      ttl  = 30
    }
    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }

  tags = {
    Name = "${var.project_name}-frontend-sd"
  }
}
