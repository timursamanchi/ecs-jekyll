#!/bin/bash

# === Config ===
CLUSTER="quoteApp-ecsCluster"
REGION="${AWS_REGION:-eu-west-2}"
LOG_FILE="ecs_health_check.log"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S %Z")

# === Start Log ===
echo ""
echo "📅 Health Check Timestamp: $TIMESTAMP" | tee "$LOG_FILE"
echo "🔍 Scanning ECS Cluster: $CLUSTER in region: $REGION" | tee -a "$LOG_FILE"
echo "=====================================================================" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# === List Services ===
SERVICE_NAMES=$(aws ecs list-services \
  --cluster "$CLUSTER" \
  --region "$REGION" \
  --query 'serviceArns' \
  --output text | tr '\t' '\n' | awk -F'/' '{print $NF}')

for SERVICE in $SERVICE_NAMES; do
  echo "📦 Service: $SERVICE" | tee -a "$LOG_FILE"
  echo "-----------------------------" | tee -a "$LOG_FILE"

  TASK_ARNS=$(aws ecs list-tasks \
    --cluster "$CLUSTER" \
    --service-name "$SERVICE" \
    --region "$REGION" \
    --desired-status RUNNING \
    --query 'taskArns' \
    --output text)

  if [[ -z "$TASK_ARNS" ]]; then
    echo "⚠️ No running tasks found for $SERVICE" | tee -a "$LOG_FILE"
    continue
  fi

  TASK_DEF_ARN=$(aws ecs describe-services \
    --cluster "$CLUSTER" \
    --services "$SERVICE" \
    --region "$REGION" \
    --query 'services[0].taskDefinition' \
    --output text)

  # Get ENI and Public IP (from first task is enough)
  TASK_ARN=$(echo "$TASK_ARNS" | awk '{print $1}')
  ENI_ID=$(aws ecs describe-tasks \
    --cluster "$CLUSTER" \
    --tasks "$TASK_ARN" \
    --region "$REGION" \
    --query 'tasks[0].attachments[0].details[?name==`networkInterfaceId`].value' \
    --output text)

  PUBLIC_IP=$(aws ec2 describe-network-interfaces \
    --network-interface-ids "$ENI_ID" \
    --region "$REGION" \
    --query 'NetworkInterfaces[0].Association.PublicIp' \
    --output text)

  echo "🔹 Task ARN: $TASK_ARN" | tee -a "$LOG_FILE"
  echo "🔹 ENI ID: $ENI_ID" | tee -a "$LOG_FILE"
  echo "🔹 Public IP: $PUBLIC_IP" | tee -a "$LOG_FILE"

  # Test every container in task definition
  CONTAINER_INFO=$(aws ecs describe-task-definition \
    --task-definition "$TASK_DEF_ARN" \
    --region "$REGION" \
    --query 'taskDefinition.containerDefinitions[*].{Name:name,Port:portMappings[0].containerPort}' \
    --output json)

  echo "$CONTAINER_INFO" | jq -c '.[]' | while read -r container; do
    NAME=$(echo "$container" | jq -r '.Name')
    PORT=$(echo "$container" | jq -r '.Port')

    TEST_URL="http://$PUBLIC_IP:$PORT"
    STATUS_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$TEST_URL")
    RESPONSE_BODY=$(curl -s --max-time 5 "$TEST_URL")

    echo "🌐 Container: $NAME" | tee -a "$LOG_FILE"
    echo "🔹 Port: $PORT" | tee -a "$LOG_FILE"
    echo "🌐 Test URL: $TEST_URL" | tee -a "$LOG_FILE"
    echo "📡 HTTP Status: $STATUS_CODE" | tee -a "$LOG_FILE"
    echo "📨 Response Body:" | tee -a "$LOG_FILE"
    echo "$RESPONSE_BODY" | tee -a "$LOG_FILE"
    echo "-----------------------------" | tee -a "$LOG_FILE"
  done

  echo "" | tee -a "$LOG_FILE"
done

echo "✅ Health check complete."
