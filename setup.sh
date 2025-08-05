#!/bin/bash
# Setup all service accounts for ML training deployment system

source .env

PROJECT_ID=${GCLOUD_PROJECT_ID:-"your-project-id"}

# echo "🚀 Setting up VM orchestrator and runner service accounts..."
# echo "📋 Project: $PROJECT_ID"
# echo ""

# # Check if project ID is set
# if [ "$PROJECT_ID" = "your-project-id" ]; then
#     echo "❌ Error: Please set GCLOUD_PROJECT_ID environment variable"
#     echo "   export GCLOUD_PROJECT_ID='your-actual-project-id'"
#     exit 1
# fi

# echo "1️⃣ Setting up VM Runner Service Account (for VMs)..."
# ./master_shell_scripts/setup/setup_runner_service_account.sh
# echo ""

# echo "2️⃣ Setting up VM Orchestrator Service Account (for deploy.py)..."
# ./master_shell_scripts/setup/setup_orchestrator_service_account.sh
# echo ""

# echo "3️⃣ Setting up VM Runner Logs Bucket..."
# ./master_shell_scripts/setup/setup_vm_runner_log_bucket.sh
# echo ""

# echo "4 Setting up VM Runner Artifact Bucket..."
# ./master_shell_scripts/setup/setup_vm_runner_artifact_bucket.sh
# echo ""

# # Update artifact and logbucket name in test-run-script.sh
# cp vm_shell_scripts/templates/template-test-run-script.sh vm_shell_scripts/test-run-script.sh
# echo "5 Updating artifact bucket name in test-run-script.sh..."
# # Replace the bucket names in the test script
# TMP_FILE=$(mktemp)
# cat vm_shell_scripts/test-run-script.sh | \
#   sed "s|your-vm-artifact-bucket|$VM_RUNNER_ARTIFACT_BUCKET_NAME|g" | \
#   sed "s|your-vm-log-bucket|$VM_RUNNER_LOGS_BUCKET_NAME|g" > "$TMP_FILE"
# mv "$TMP_FILE" vm_shell_scripts/test-run-script.sh
# chmod +x vm_shell_scripts/test-run-script.sh
# echo ""

# # Update artifact and logbucket name in main-run-script.sh
# cp vm_shell_scripts/templates/template-main-run-script.sh vm_shell_scripts/main-run-script.sh
# echo "6 Updating artifact bucket name in main-run-script.sh..."
# # Replace the bucket names in the run main script
# TMP_FILE=$(mktemp)
# cat vm_shell_scripts/main-run-script.sh | \
#   sed "s|your-vm-artifact-bucket|$VM_RUNNER_ARTIFACT_BUCKET_NAME|g" | \
#   sed "s|your-vm-log-bucket|$VM_RUNNER_LOGS_BUCKET_NAME|g" > "$TMP_FILE"
# mv "$TMP_FILE" vm_shell_scripts/main-run-script.sh
# chmod +x vm_shell_scripts/main-run-script.sh
# echo ""

echo "7 Setting up VM Runner Network..."
./master_shell_scripts/setup/setup_network.sh
echo ""
