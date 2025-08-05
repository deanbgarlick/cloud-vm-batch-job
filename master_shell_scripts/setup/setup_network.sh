#!/bin/bash
set -e

source .env

# Configuration variables
NETWORK_NAME=$NETWORK_NAME
SUBNET_NAME=$SUBNET_NAME
REGION=$REGION
SUBNET_RANGE=$SUBNET_RANGE
NAT_GATEWAY_NAME=$NAT_GATEWAY_NAME
ROUTER_NAME=$ROUTER_NAME

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Starting network setup...${NC}"

# Create VPC network
echo "Creating VPC network: $NETWORK_NAME"
if ! gcloud compute networks describe "$NETWORK_NAME" &>/dev/null; then
    gcloud compute networks create "$NETWORK_NAME" \
        --subnet-mode=custom \
        --bgp-routing-mode=regional \
        --description="Network for VM runner instances"
    echo -e "${GREEN}VPC network created successfully${NC}"
else
    echo "VPC network already exists"
fi

# Create subnet
echo "Creating subnet: $SUBNET_NAME"
if ! gcloud compute networks subnets describe "$SUBNET_NAME" --region="$REGION" &>/dev/null; then
    gcloud compute networks subnets create "$SUBNET_NAME" \
        --network="$NETWORK_NAME" \
        --region="$REGION" \
        --range="$SUBNET_RANGE" \
        --description="Subnet for VM runner instances"
    echo -e "${GREEN}Subnet created successfully${NC}"
else
    echo "Subnet already exists"
fi

# Create Cloud Router
echo "Creating Cloud Router: $ROUTER_NAME"
if ! gcloud compute routers describe "$ROUTER_NAME" --region="$REGION" &>/dev/null; then
    gcloud compute routers create "$ROUTER_NAME" \
        --network="$NETWORK_NAME" \
        --region="$REGION" \
        --description="Router for VM runner NAT gateway"
    echo -e "${GREEN}Cloud Router created successfully${NC}"
else
    echo "Cloud Router already exists"
fi

# Create Cloud NAT
echo "Creating Cloud NAT: $NAT_GATEWAY_NAME"
if ! gcloud compute routers nats describe "$NAT_GATEWAY_NAME" \
    --router="$ROUTER_NAME" \
    --region="$REGION" &>/dev/null; then
    gcloud compute routers nats create "$NAT_GATEWAY_NAME" \
        --router="$ROUTER_NAME" \
        --region="$REGION" \
        --nat-all-subnet-ip-ranges \
        --auto-allocate-nat-external-ips
    echo -e "${GREEN}Cloud NAT created successfully${NC}"
else
    echo "Cloud NAT already exists"
fi

# Create firewall rules
echo "Creating firewall rules..."

# Allow internal communication
INTERNAL_RULE_NAME="$NETWORK_NAME-allow-internal"
if ! gcloud compute firewall-rules describe "$INTERNAL_RULE_NAME" &>/dev/null; then
    gcloud compute firewall-rules create "$INTERNAL_RULE_NAME" \
        --network="$NETWORK_NAME" \
        --allow=tcp,udp,icmp \
        --source-ranges="$SUBNET_RANGE" \
        --description="Allow internal communication between instances"
    echo -e "${GREEN}Internal firewall rule created successfully${NC}"
else
    echo "Internal firewall rule already exists"
fi

# Allow SSH access
SSH_RULE_NAME="$NETWORK_NAME-allow-ssh"
if ! gcloud compute firewall-rules describe "$SSH_RULE_NAME" &>/dev/null; then
    gcloud compute firewall-rules create "$SSH_RULE_NAME" \
        --network="$NETWORK_NAME" \
        --allow=tcp:22 \
        --source-ranges="0.0.0.0/0" \
        --description="Allow SSH access"
    echo -e "${GREEN}SSH firewall rule created successfully${NC}"
else
    echo "SSH firewall rule already exists"
fi

echo -e "${GREEN}Network setup completed successfully!${NC}"
echo "Network: $NETWORK_NAME"
echo "Subnet: $SUBNET_NAME ($SUBNET_RANGE)"
echo "NAT Gateway: $NAT_GATEWAY_NAME"
echo "Router: $ROUTER_NAME"
echo "Region: $REGION" 