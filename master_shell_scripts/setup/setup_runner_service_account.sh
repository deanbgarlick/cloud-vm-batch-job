#!/bin/bash
# Setup service account for runner VM with bucket access

# Debug: Print current directory
echo "Current directory: $(pwd)"

source .env

# Debug: Print environment variables
echo "GCLOUD_PROJECT_ID: $GCLOUD_PROJECT_ID"
echo "VM_RUNNER_SERVICE_ACCOUNT_NAME: $VM_RUNNER_SERVICE_ACCOUNT_NAME"

# Check required environment variables
if [ -z "$GCLOUD_PROJECT_ID" ]; then
    echo "❌ Error: GCLOUD_PROJECT_ID not set in .env"
    echo "   Please set GCLOUD_PROJECT_ID in your .env file"
    exit 1
fi

# Check required environment variables
if [ -z "$VM_RUNNER_SERVICE_ACCOUNT_NAME" ]; then
    echo "❌ Error: VM_RUNNER_SERVICE_ACCOUNT_NAME not set in .env"
    echo "   Please set VM_RUNNER_SERVICE_ACCOUNT_NAME in your .env file"
    exit 1
fi

# Set variables
PROJECT_ID=$GCLOUD_PROJECT_ID
VM_RUNNER_SERVICE_ACCOUNT_EMAIL="${VM_RUNNER_SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

echo "🔧 Setting up service account for runner..."
echo "📋 Project ID: $PROJECT_ID"

# Verify project access
if ! gcloud projects describe $PROJECT_ID >/dev/null 2>&1; then
    echo "❌ Error: Cannot access project $PROJECT_ID"
    echo "   Please verify:"
    echo "   1. You are logged into the correct Google Cloud account"
    echo "   2. You have sufficient permissions"
    echo "   3. The project ID is correct"
    exit 1
fi

# Create service account
if ! gcloud iam service-accounts describe "$VM_RUNNER_SERVICE_ACCOUNT_EMAIL" --project "$PROJECT_ID" &>/dev/null; then
    gcloud iam service-accounts create $VM_RUNNER_SERVICE_ACCOUNT_NAME \
        --display-name="Runner Service Account" \
        --description="Service account for runner VMs to access buckets"
else
    echo "✓ Service account already exists, proceeding with permission setup..."
fi

# Grant bucket permissions
echo "📦 Granting bucket permissions..."
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$VM_RUNNER_SERVICE_ACCOUNT_EMAIL" \
    --role="roles/storage.objectAdmin"

# Optional: Grant logging permissions (for better monitoring)
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:$VM_RUNNER_SERVICE_ACCOUNT_EMAIL" \
    --role="roles/logging.logWriter"

# Create and download key (optional, for local testing)
echo "🔑 Creating service account key..."
gcloud iam service-accounts keys create ./secrets/vm-runner-sa-key.json \
    --iam-account=$VM_RUNNER_SERVICE_ACCOUNT_EMAIL

echo "✅ Service account setup complete!"
echo "📧 Service Account Email: $VM_RUNNER_SERVICE_ACCOUNT_EMAIL"

echo ""
echo "To use with VM deployment:"
echo "  export VM_RUNNER_SERVICE_ACCOUNT='$VM_RUNNER_SERVICE_ACCOUNT_EMAIL'"
echo ""
echo "To test locally:"
echo "  export GOOGLE_APPLICATION_CREDENTIALS='./secrets/vm-runner-sa-key.json'" 