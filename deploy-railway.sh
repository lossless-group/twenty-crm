#!/bin/bash

# Railway Deployment Script for Twenty CRM Multi-Workspace
# This script sets up a complete Railway project with all necessary services

set -e

echo "🚀 Setting up Twenty CRM on Railway with Multi-Workspace Support"

# Check if Railway CLI is installed
if ! command -v railway &> /dev/null; then
    echo "❌ Railway CLI not found. Please install it first:"
    echo "npm install -g @railway/cli"
    exit 1
fi

# Login to Railway (if not already logged in)
echo "🔐 Checking Railway authentication..."
if ! railway whoami &> /dev/null; then
    echo "Please login to Railway:"
    railway login
fi

# Create new Railway project
echo "📦 Creating new Railway project..."
PROJECT_NAME="twenty-crm-multiworkspace"
railway project new "$PROJECT_NAME"

# Add PostgreSQL service
echo "🐘 Adding PostgreSQL database..."
railway add --database postgresql

# Add Redis service
echo "🔴 Adding Redis service..."
railway add --database redis

# Generate secure secrets
echo "🔐 Generating secure secrets..."
APP_SECRET=$(openssl rand -hex 32)
ACCESS_TOKEN_SECRET=$(openssl rand -hex 32)
LOGIN_TOKEN_SECRET=$(openssl rand -hex 32)
REFRESH_TOKEN_SECRET=$(openssl rand -hex 32)
FILE_TOKEN_SECRET=$(openssl rand -hex 32)

# Set environment variables
echo "⚙️ Setting environment variables..."
railway variables set \
    NODE_ENV=production \
    IS_MULTIWORKSPACE_ENABLED=true \
    APP_SECRET="$APP_SECRET" \
    ACCESS_TOKEN_SECRET="$ACCESS_TOKEN_SECRET" \
    LOGIN_TOKEN_SECRET="$LOGIN_TOKEN_SECRET" \
    REFRESH_TOKEN_SECRET="$REFRESH_TOKEN_SECRET" \
    FILE_TOKEN_SECRET="$FILE_TOKEN_SECRET" \
    STORAGE_TYPE=local \
    STORAGE_LOCAL_PATH=.local-storage \
    MUTATION_MAXIMUM_AFFECTED_RECORDS=1000 \
    CHROME_EXTENSION_ID=bggmipldbceihilonnbpgoeclgbkblkp \
    DISABLE_CRON_JOBS_REGISTRATION=false \
    DISABLE_DB_MIGRATIONS=false

echo "🌐 Setting up domain configuration..."
# Note: SERVER_URL and FRONT_BASE_URL will be set automatically by Railway

# Deploy the application
echo "🚀 Deploying Twenty CRM..."
railway up --detach

echo "✅ Deployment initiated! Your Twenty CRM instance is being deployed."
echo ""
echo "📋 Next steps:"
echo "1. Wait for deployment to complete (check Railway dashboard)"
echo "2. Once deployed, visit your app URL to set up workspaces"
echo "3. Create three separate workspaces for your clients"
echo "4. Configure custom domains if needed"
echo ""
echo "🔧 To check deployment status:"
echo "railway status"
echo ""
echo "📊 To view logs:"
echo "railway logs"
echo ""
echo "🌍 To get your app URL:"
echo "railway domain"

# Save deployment info
cat > deployment-info.txt << EOF
Twenty CRM Multi-Workspace Deployment
=====================================

Project: $PROJECT_NAME
Deployed: $(date)

Generated Secrets:
- APP_SECRET: $APP_SECRET
- ACCESS_TOKEN_SECRET: $ACCESS_TOKEN_SECRET
- LOGIN_TOKEN_SECRET: $LOGIN_TOKEN_SECRET
- REFRESH_TOKEN_SECRET: $REFRESH_TOKEN_SECRET
- FILE_TOKEN_SECRET: $FILE_TOKEN_SECRET

Configuration:
- Multi-workspace: ENABLED
- Storage: Local (Railway persistent volumes)
- Database: PostgreSQL (Railway managed)
- Cache: Redis (Railway managed)

Next Steps:
1. Access your deployed app via Railway domain
2. Create workspaces for each client
3. Configure custom domains if needed
4. Set up email configuration (optional)

Railway Commands:
- Check status: railway status
- View logs: railway logs
- Get domain: railway domain
- Open dashboard: railway open
EOF

echo "💾 Deployment information saved to deployment-info.txt"