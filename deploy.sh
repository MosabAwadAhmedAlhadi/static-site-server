#!/bin/bash

# Load environment variables
source .env

# Rsync command
rsync -avzP --delete --exclude '.github/' $LOCAL_SITE_PATH $SERVER_USER@$SERVER_IP:$SERVER_PATH

# Reload Nginx
ssh $SERVER_USER@$SERVER_IP "sudo systemctl reload nginx"

echo "🚀 Deployment complete!"
