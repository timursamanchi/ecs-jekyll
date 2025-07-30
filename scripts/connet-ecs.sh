#!/bin/bash

# List all ECS clusters and loop through them
clusters=$(aws ecs list-clusters --query "clusterArns[*]" --output text)

for cluster_arn in $clusters; do
  cluster_name=$(basename $cluster_arn)
  echo "Checking cluster: $cluster_name"

  # Try to list running tasks for the service
  task_arn=$(aws ecs list-tasks \
    --cluster "$cluster_name" \
    --service-name quoteApp-frontend-service \
    --desired-status RUNNING \
    --query "taskArns[0]" \
    --output text 2>/dev/null)

  if [[ -z "$task_arn" || "$task_arn" == "None" ]]; then
    echo "❌ No running tasks found or service 'quoteApp-frontend-service' not found in cluster '$cluster_name'. Skipping."
    continue
  fi

  echo "✅ Found task: $task_arn"

  # Get container name
  container_name=$(aws ecs describe-tasks \
    --cluster "$cluster_name" \
    --tasks "$task_arn" \
    --query "tasks[0].containers[0].name" \
    --output text)

  if [[ -z "$container_name" || "$container_name" == "None" ]]; then
    echo "❌ Could not get container name. Skipping."
    continue
  fi

  echo "📦 Container name: $container_name"

  # Get network interface ID
  eni_id=$(aws ecs describe-tasks \
    --cluster "$cluster_name" \
    --tasks "$task_arn" \
    --query "tasks[0].attachments[0].details[?name=='networkInterfaceId'].value" \
    --output text)

  # Try to get public IP (if possible)
  if [[ -n "$eni_id" && "$eni_id" != "None" ]]; then
    public_ip=$(aws ec2 describe-network-interfaces \
      --network-interface-ids "$eni_id" \
      --query "NetworkInterfaces[0].Association.PublicIp" \
      --output text)
    echo "🌍 Public IP: $public_ip"
  else
    echo "⚠️ No ENI found or this is likely a Fargate task without a public IP."
  fi

  # Ask user if they want to connect
  read -p "🔌 Connect to this container? (y/n): " answer
  if [[ "$answer" == "y" || "$answer" == "Y" ]]; then
    echo "🚀 Connecting..."
    aws ecs execute-command \
      --cluster "$cluster_name" \
      --task "$task_arn" \
      --container "$container_name" \
      --command "/bin/sh" \
      --interactive
  else
    echo "⏭️  Skipping connection."
  fi

done
