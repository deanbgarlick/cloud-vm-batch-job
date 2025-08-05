#!/bin/bash
# Setup logging bucket for VM runner runs

source .env

PROJECT_ID=${GCLOUD_PROJECT_ID:-$(gcloud config get-value project)}
BUCKET_NAME=$VM_RUNNER_LOGS_BUCKET_NAME

echo "📦 Setting up logging bucket: gs://$BUCKET_NAME"

# Create the bucket (regional for better performance/cost)
echo "Creating bucket..."
gsutil mb -p $PROJECT_ID -c STANDARD -l us-central1 gs://$BUCKET_NAME

# Set lifecycle policy to delete old logs after 90 days (optional cost saving)
echo "Setting lifecycle policy..."
cat > lifecycle.json << 'EOF'
{
  "lifecycle": {
    "rule": [
      {
        "action": {"type": "Delete"},
        "condition": {"age": 90}
      }
    ]
  }
}
EOF

gsutil lifecycle set lifecycle.json gs://$BUCKET_NAME
rm lifecycle.json

# Enable versioning (keeps multiple versions of files)
echo "Enabling versioning..."
gsutil versioning set on gs://$BUCKET_NAME

# Set public access prevention (security)
echo "Setting security policies..."
gsutil pap set enforced gs://$BUCKET_NAME

# Grant access to VM runner service account
echo "Granting access to VM runner service account..."
gsutil iam ch serviceAccount:${VM_RUNNER_SERVICE_ACCOUNT_NAME}@${PROJECT_ID}.iam.gserviceaccount.com:objectAdmin gs://$BUCKET_NAME

echo "✅ Logging bucket setup complete!"
echo ""
echo "📊 Bucket: gs://$BUCKET_NAME"
echo "🌍 Region: us-central1"
echo "🔄 Versioning: Enabled"
echo "🗑️  Lifecycle: Delete logs after 90 days"
echo "🔒 Security: Public access prevented"
echo ""
