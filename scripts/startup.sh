#!/bin/bash
set -e

# Disable and wait for any automatic apt processes to release the lock
systemctl disable --now unattended-upgrades 2>/dev/null || true
while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
  echo "Waiting for dpkg lock..."
  sleep 5
done

# Update system
apt-get update && apt-get upgrade -y

# Install git
apt-get install -y git curl

# Install Node.js 20.x
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

# Install Cursor CLI
curl https://cursor.com/install -fsS | bash

# Add common install locations to PATH so `which` can find the binary
export PATH="$PATH:/root/.cursor/bin:/root/.local/bin:/usr/local/bin:/usr/bin"

# Clone repository
cd /opt
git clone YOUR_REPO_URL cursor-agent
cd cursor-agent

# Install dependencies
npm install

# Create environment file (hardcoded for spot instance)
cat > .env << EOF
MONGODB_URI=your-mongodb-connection-string
API_KEY=your-api-key-for-auth
CURSOR_API_KEY=your-cursor-api-key
RESPONSE_INSTRUCTIONS="Provide concise responses under 8000 characters suitable for voice interaction via Alexa. Do not ask follow-up questions. Answer directly and completely in a single response."
PORT=80
EOF

# Export Cursor API key for CLI authentication
export CURSOR_API_KEY=your-cursor-api-key

# Install PM2 for process management
npm install -g pm2

# Start application with PM2
pm2 start src/server.js --name cursor-agent
pm2 save
pm2 startup systemd -u root --hp /root

echo "Setup complete! Application running on port 80"
