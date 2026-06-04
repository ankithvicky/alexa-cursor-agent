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

# Install git and curl
apt-get install -y git curl

# Install Node.js 20.x
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

# Allow Node.js to bind to privileged ports (< 1024) without root
setcap cap_net_bind_service=+ep $(which node)

# Install PM2 globally (needs root)
npm install -g pm2

# Create dedicated service user
useradd -m -s /bin/bash cursoragent
echo "cursoragent:Cursor@123" | chpasswd

# Run all user-space setup as cursoragent
sudo -u cursoragent -H bash << 'USERSCRIPT'
set -e

export PATH="$HOME/.cursor/bin:$HOME/.local/bin:/usr/local/bin:/usr/bin:$PATH"

# Install Cursor CLI (installs to ~/.cursor/bin)
curl https://cursor.com/install -fsS | bash

# Clone repository
git clone YOUR_REPO_URL ~/cursor-agent
cd ~/cursor-agent

# Install dependencies
npm install

# Create environment file
cat > .env << EOF
MONGODB_URI=your-mongodb-connection-string
API_KEY=your-api-key-for-auth
CURSOR_API_KEY=your-cursor-api-key
RESPONSE_INSTRUCTIONS="Provide concise responses under 8000 characters suitable for voice interaction via Alexa. Do not ask follow-up questions. Answer directly and completely in a single response."
PORT=80
EOF

# Export Cursor API key for CLI authentication
export CURSOR_API_KEY=your-cursor-api-key

# Start application with PM2
pm2 start src/server.js --name cursor-agent
pm2 save
USERSCRIPT

# Set up PM2 systemd startup for cursoragent (must run as root)
PM2_HOME=/home/cursoragent/.pm2 \
  env PATH="$PATH:/usr/bin" /usr/lib/node_modules/pm2/bin/pm2 \
  startup systemd -u cursoragent --hp /home/cursoragent | tail -1 | bash

echo "Setup complete! Application running on port 80"
echo "To test: sudo su - cursoragent   (password: Cursor@123)"
