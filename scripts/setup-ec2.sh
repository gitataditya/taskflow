#!/bin/bash

# TaskFlow EC2 Setup Script
# This script sets up the initial deployment environment on EC2

set -e

echo "🚀 Starting TaskFlow EC2 Setup..."

# Update system packages
echo "📦 Updating system packages..."
sudo apt update -y
sudo apt upgrade -y

# Install required packages
echo "📋 Installing required packages..."
sudo apt install -y python3 python3-pip python3-venv nginx git curl

# Create application directory
echo "📁 Creating application directory..."
sudo mkdir -p /var/www
cd /var/www

# Clone repository if it doesn't exist
if [ ! -d "taskflow" ]; then
    echo "📥 Cloning repository..."
    sudo git clone https://github.com/gitataditya/taskflow.git
else
    echo "📂 Repository already exists, pulling latest changes..."
    cd taskflow
    sudo git pull origin main
    cd /var/www
fi

# Set proper ownership
echo "🔐 Setting proper ownership..."
sudo chown -R ubuntu:ubuntu taskflow
cd taskflow

# Create virtual environment
echo "🐍 Creating virtual environment..."
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi

# Activate virtual environment and install dependencies
echo "📦 Installing Python dependencies..."
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# Initialize database
echo "🗄️ Initializing database..."
python -c "from app import app, db; app.app_context().push(); db.create_all()"

# Create systemd service
echo "⚙️ Creating systemd service..."
sudo tee /etc/systemd/system/taskflow.service > /dev/null << 'EOF'
[Unit]
Description=TaskFlow Flask Application
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/var/www/taskflow
Environment="PATH=/var/www/taskflow/venv/bin"
Environment="FLASK_ENV=production"
ExecStart=/var/www/taskflow/venv/bin/python app.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Configure nginx
echo "🌐 Configuring nginx..."
sudo tee /etc/nginx/sites-available/taskflow > /dev/null << 'EOF'
server {
    listen 80;
    server_name _;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    location /static {
        alias /var/www/taskflow/static;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
EOF

# Enable nginx site
echo "🔗 Enabling nginx site..."
sudo ln -sf /etc/nginx/sites-available/taskflow /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# Test nginx configuration
echo "🧪 Testing nginx configuration..."
sudo nginx -t

# Reload systemd and start services
echo "🔄 Starting services..."
sudo systemctl daemon-reload
sudo systemctl enable taskflow
sudo systemctl start taskflow
sudo systemctl enable nginx
sudo systemctl restart nginx

# Check service status
echo "📊 Checking service status..."
sudo systemctl status taskflow --no-pager -l
sudo systemctl status nginx --no-pager -l

# Show final status
echo ""
echo "✅ TaskFlow setup completed!"
echo "🌐 Your application should be available at: http://$(curl -s http://checkip.amazonaws.com/)"
echo ""
echo "📝 Service commands:"
echo "  - Check status: sudo systemctl status taskflow"
echo "  - View logs: sudo journalctl -u taskflow -f"
echo "  - Restart: sudo systemctl restart taskflow"
echo ""