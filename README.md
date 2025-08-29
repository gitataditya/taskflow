# TaskFlow Enterprise - Python Edition

A modern, feature-rich task management application built with Flask, featuring a beautiful UI, multiple themes, and comprehensive task organization capabilities.

## Features

### 🎨 Modern UI Design
- **5 Color Themes**: Default Blue, Dark Mode, Light Mode, Nature Green, Royal Purple
- **Responsive Design**: Optimized for desktop, tablet, and mobile devices
- **Smooth Animations**: Enhanced user experience with modern transitions

### 📊 Analytics Dashboard
- **Task Statistics**: Real-time overview of task completion rates
- **Visual Cards**: Beautiful, spacious cards with hover effects
- **Technology Stack Display**: Information about the underlying technologies

### ⚙️ Advanced Settings
- **Theme Customization**: Easy theme switching with localStorage persistence
- **System Information**: Runtime details and technology stack
- **Data Management**: Import/export functionality (coming soon)

### ✨ Enhanced Task Management
- **Smart Filters**: Interactive filter buttons with task counts
- **Sorting Options**: Sort by date, title, or status
- **Rich Task Creation**: Detailed forms with categories and priorities
- **Bulk Actions**: Manage multiple tasks efficiently

## Technology Stack

- **Backend**: Flask 3.0.0
- **Database**: SQLAlchemy + SQLite
- **Frontend**: Vanilla JavaScript + CSS3
- **Template Engine**: Jinja2
- **Deployment**: GitHub Actions + EC2

## Local Development

### Prerequisites
- Python 3.9+
- pip
- Git

### Setup
```bash
# Clone the repository
git clone https://github.com/gitataditya/taskflow.git
cd taskflow

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run the application
python app.py
```

The application will be available at `http://localhost:8000`

## Deployment

### GitHub Actions (Recommended)

This repository includes automated deployment via GitHub Actions. To deploy:

1. **Set up your EC2 instance** with Python, nginx, and required dependencies
2. **Add GitHub Secrets** in your repository settings:
   - `EC2_HOST`: Your EC2 public IP or domain name
   - `EC2_USERNAME`: SSH username (usually `ubuntu` or `ec2-user`)
   - `EC2_PRIVATE_KEY`: Content of your EC2 private key (.pem file)

3. **Push to main branch** - deployment happens automatically!

### Manual EC2 Deployment

<details>
<summary>Click to expand manual deployment steps</summary>

#### 1. Connect to EC2
```bash
ssh -i your-key.pem ubuntu@your-ec2-ip
```

#### 2. Install Dependencies
```bash
sudo apt update
sudo apt install python3 python3-pip python3-venv nginx git -y
```

#### 3. Clone and Setup
```bash
cd /var/www
sudo git clone https://github.com/gitataditya/taskflow.git
sudo chown -R ubuntu:ubuntu taskflow
cd taskflow
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

#### 4. Create Systemd Service
```bash
sudo nano /etc/systemd/system/taskflow.service
```

Add:
```ini
[Unit]
Description=TaskFlow Flask App
After=network.target

[Service]
User=ubuntu
WorkingDirectory=/var/www/taskflow
Environment="PATH=/var/www/taskflow/venv/bin"
ExecStart=/var/www/taskflow/venv/bin/python app.py
Restart=always

[Install]
WantedBy=multi-user.target
```

#### 5. Configure Nginx
```bash
sudo nano /etc/nginx/sites-available/taskflow
```

Add:
```nginx
server {
    listen 80;
    server_name your-domain.com;

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
```

#### 6. Enable and Start Services
```bash
sudo ln -s /etc/nginx/sites-available/taskflow /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default  # Remove default site
sudo systemctl enable taskflow
sudo systemctl start taskflow
sudo systemctl restart nginx
```

</details>

## API Endpoints

- `GET /` - Main application interface
- `GET /api/tasks` - Get all tasks
- `POST /api/tasks` - Create new task
- `GET /api/tasks/<id>` - Get specific task
- `PUT /api/tasks/<id>` - Update task
- `PATCH /api/tasks/<id>/complete` - Toggle task completion
- `DELETE /api/tasks/<id>` - Delete task

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Screenshots

### Dashboard
Modern analytics dashboard with task statistics and recent tasks overview.

### Create Task
Spacious task creation form with categories, priorities, and detailed descriptions.

### Manage Tasks
Advanced filtering and sorting capabilities with interactive buttons.

### Settings
Comprehensive settings panel with theme customization and system information.

---

**Built with ❤️ using Flask and modern web technologies**