#######################################
# Random suffix for Auto Scaling Group name
# example:
# ASG name; random suffix ensures uniqueness across multiple deployments
# name = "k8s-workers-asg-${random_string.asg_suffix.result}"
#######################################
resource "random_string" "asg_suffix" {
  length  = 6     # Length of the random string
  upper   = false # Lowercase only
  special = false # No special chars
}
# ----------------------------------------------------