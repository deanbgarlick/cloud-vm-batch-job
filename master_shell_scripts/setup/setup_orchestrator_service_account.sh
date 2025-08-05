#!/bin/bash
# Setup orchestrator service account for running deploy.py

source .env

echo "GCLOUD_PROJECT_ID: $GCLOUD_PROJECT_ID"
echo "VM_ORCHESTRATOR_SERVICE_ACCOUNT_NAME: $VM_ORCHESTRATOR_SERVICE_ACCOUNT_NAME"

PROJECT_ID=${GCLOUD_PROJECT_ID}
SA_EMAIL="${VM_ORCHESTRATOR_SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

echo "🚀 Setting up orchestrator service account for deploy.py..."

# Check if service account exists, create if it doesn't
if ! gcloud iam service-accounts describe "$SA_EMAIL" --project "$PROJECT_ID" &>/dev/null; then
    gcloud iam service-accounts create $VM_ORCHESTRATOR_SERVICE_ACCOUNT_NAME \
        --display-name="Orchestrator Service Account" \
        --description="Service account for running deploy.py to manage VMs"
else
    echo "✓ Service account already exists, proceeding with permission setup..."
fi

echo "🔧 Granting compute permissions..."

# Grant compute instance management permissions
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SA_EMAIL" \
    --role="roles/compute.instanceAdmin.v1"

# Grant permission to read/write compute images and disks
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SA_EMAIL" \
    --role="roles/compute.storageAdmin"

# Grant service account user role (to assign service accounts to VMs)
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SA_EMAIL" \
    --role="roles/iam.serviceAccountUser"

# Grant monitoring permissions (for logs)
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SA_EMAIL" \
    --role="roles/logging.viewer"

# Optional: Grant project viewer (for general project access)
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$SA_EMAIL" \
    --role="roles/viewer"

echo "🔑 Creating service account key..."
# Create and download key for local/CI usage
gcloud iam service-accounts keys create ./secrets/vm-orchestrator-sa-key.json \
    --iam-account=$SA_EMAIL

echo "✅ orchestrator service account setup complete!"
echo "📧 orchestrator SA Email: $SA_EMAIL"
echo "🖥️  Permissions: Compute instance management, service account assignment"
echo ""
echo "To use this service account:"
echo "  export GOOGLE_APPLICATION_CREDENTIALS='./secrets/vm-orchestrator-sa-key.json'"
echo "  python deploy.py"
echo ""
echo "For CI/CD pipelines:"
echo "  # Upload ./secrets/vm-orchestrator-sa-key.json as secret"
echo "  # Set GOOGLE_APPLICATION_CREDENTIALS environment variable"
echo ""
echo "⚠️  Security Note:"
echo "  - Keep ./secrets/vm-orchestrator-sa-key.json secure and private"
echo "  - Consider using Workload Identity in GKE/Cloud Run instead"
echo "  - Rotate keys regularly" 