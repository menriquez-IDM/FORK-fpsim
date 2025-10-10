# FPsim Shiny App - Deployment Guide

This guide covers deploying the FPsim Shiny app to various platforms for production use.

## Table of Contents
- [Local Development](#local-development)
- [Shiny Server (Self-Hosted)](#shiny-server-self-hosted)
- [ShinyApps.io](#shinyappsio)
- [RStudio Connect](#rstudio-connect)
- [Docker Deployment](#docker-deployment)
- [AWS/Cloud Deployment](#awscloud-deployment)

---

## Local Development

### Setup
```r
setwd("/Users/mine/fpgit/FORK-fpsim/fpsim_shiny_app")
source("install_packages.R")  # First time only
shiny::runApp()
```

### Configuration
- Default port: Random (auto-assigned)
- Custom port: `shiny::runApp(port = 3838)`
- External access: `shiny::runApp(host = "0.0.0.0", port = 3838)`

---

## Shiny Server (Self-Hosted)

### Prerequisites
- Linux server (Ubuntu/Debian recommended)
- Shiny Server installed
- R and Python installed

### Installation Steps

#### 1. Install Shiny Server
```bash
# Ubuntu/Debian
sudo apt-get install gdebi-core
wget https://download3.rstudio.org/ubuntu-18.04/x86_64/shiny-server-1.5.20.1002-amd64.deb
sudo gdebi shiny-server-1.5.20.1002-amd64.deb
```

#### 2. Deploy App
```bash
# Copy app to Shiny Server directory
sudo cp -r /path/to/fpsim_shiny_app /srv/shiny-server/fpsim

# Set permissions
sudo chown -R shiny:shiny /srv/shiny-server/fpsim
```

#### 3. Configure Python Environment
```bash
# Install Python packages system-wide or in a virtual environment
cd /srv/shiny-server/fpsim
python3 -m venv venv
source venv/bin/activate
pip install fpsim
```

#### 4. Update app paths in `global.R`
```r
# Modify venv_path for server deployment
venv_path <- "/srv/shiny-server/fpsim/venv"
```

#### 5. Restart Shiny Server
```bash
sudo systemctl restart shiny-server
```

#### 6. Access App
```
http://your-server-ip:3838/fpsim/
```

### Shiny Server Configuration
Edit `/etc/shiny-server/shiny-server.conf`:

```nginx
server {
  listen 3838;
  
  location /fpsim {
    app_dir /srv/shiny-server/fpsim;
    log_dir /var/log/shiny-server;
    
    # Increase timeout for long simulations
    app_idle_timeout 600;
    app_init_timeout 120;
    
    # Allow more concurrent connections
    simple_scheduler 15;
  }
}
```

---

## ShinyApps.io

### Prerequisites
- ShinyApps.io account
- `rsconnect` R package

### Setup
```r
install.packages("rsconnect")

# Configure account (get tokens from shinyapps.io/tokens)
rsconnect::setAccountInfo(
  name = "your-account",
  token = "your-token",
  secret = "your-secret"
)
```

### Deployment

#### 1. Prepare App
```r
setwd("/Users/mine/fpgit/FORK-fpsim/fpsim_shiny_app")
```

#### 2. Deploy
```r
rsconnect::deployApp(
  appName = "fpsim-interactive",
  appTitle = "FPsim Interactive Simulator",
  account = "your-account"
)
```

### Important Notes
- **Python packages:** ShinyApps.io has limited Python support
- **Workaround:** Pre-compute results or use R-only features
- **Alternative:** Consider RStudio Connect or self-hosted for full Python integration

---

## RStudio Connect

### Prerequisites
- RStudio Connect installed
- Access to RStudio Connect server
- `rsconnect` package

### Deployment

#### 1. Configure Connection
```r
rsconnect::connectUser(
  server = "https://your-connect-server.com",
  apiKey = "your-api-key"
)
```

#### 2. Deploy
```r
rsconnect::deployApp(
  appDir = "/Users/mine/fpgit/FORK-fpsim/fpsim_shiny_app",
  appName = "fpsim-interactive",
  server = "your-connect-server",
  account = "your-account"
)
```

#### 3. Configure Python Environment
In RStudio Connect admin panel:
1. Go to app settings
2. Configure Python version
3. Install FPsim via `requirements.txt`

### Requirements File
Create `requirements.txt`:
```
fpsim>=3.3.1
numpy>=1.20.0
pandas>=1.3.0
scipy>=1.7.0
```

---

## Docker Deployment

### Dockerfile
Create `Dockerfile`:

```dockerfile
FROM rocker/shiny-verse:latest

# Install system dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Create virtual environment
RUN python3 -m venv /opt/venv

# Install Python packages
RUN /opt/venv/bin/pip install --upgrade pip && \
    /opt/venv/bin/pip install fpsim numpy pandas scipy

# Install R packages
RUN R -e "install.packages(c('shiny', 'bslib', 'reticulate', 'plotly', 'DT', 'shinyjs', 'jsonlite'))"

# Copy app
COPY . /srv/shiny-server/fpsim/

# Set permissions
RUN chown -R shiny:shiny /srv/shiny-server/fpsim

# Expose port
EXPOSE 3838

# Run app
CMD ["/usr/bin/shiny-server"]
```

### Build and Run
```bash
# Build image
docker build -t fpsim-shiny .

# Run container
docker run -d -p 3838:3838 --name fpsim-app fpsim-shiny

# Access
open http://localhost:3838/fpsim
```

### Docker Compose
Create `docker-compose.yml`:

```yaml
version: '3.8'

services:
  fpsim-app:
    build: .
    ports:
      - "3838:3838"
    volumes:
      - ./logs:/var/log/shiny-server
    restart: unless-stopped
    environment:
      - RETICULATE_PYTHON=/opt/venv/bin/python
```

Run:
```bash
docker-compose up -d
```

---

## AWS/Cloud Deployment

### AWS EC2

#### 1. Launch EC2 Instance
- AMI: Ubuntu 22.04 LTS
- Instance type: t3.medium (2 vCPU, 4GB RAM minimum)
- Storage: 20GB SSD
- Security group: Allow inbound on port 3838

#### 2. Install Dependencies
```bash
# SSH into instance
ssh -i your-key.pem ubuntu@your-instance-ip

# Update system
sudo apt-get update && sudo apt-get upgrade -y

# Install R
sudo apt-get install -y r-base r-base-dev

# Install Shiny Server
wget https://download3.rstudio.org/ubuntu-18.04/x86_64/shiny-server-1.5.20.1002-amd64.deb
sudo gdebi -n shiny-server-1.5.20.1002-amd64.deb

# Install Python
sudo apt-get install -y python3 python3-pip python3-venv
```

#### 3. Deploy App
```bash
# Clone repo or upload app
git clone https://github.com/your-repo/fpsim.git
sudo cp -r fpsim/fpsim_shiny_app /srv/shiny-server/fpsim

# Setup Python environment
cd /srv/shiny-server/fpsim
python3 -m venv venv
source venv/bin/activate
pip install fpsim

# Install R packages
sudo su - -c "R -e \"install.packages(c('shiny', 'bslib', 'reticulate', 'plotly', 'DT', 'shinyjs', 'jsonlite'))\""

# Set permissions
sudo chown -R shiny:shiny /srv/shiny-server/fpsim

# Restart Shiny Server
sudo systemctl restart shiny-server
```

#### 4. Configure DNS (Optional)
- Point domain to EC2 public IP
- Use Route 53 or your DNS provider
- Access: `http://your-domain.com:3838/fpsim`

### AWS ECS (Fargate)

Deploy using Docker image to ECS for auto-scaling and managed infrastructure.

1. Push Docker image to ECR
2. Create ECS task definition
3. Create ECS service with Fargate
4. Configure Application Load Balancer
5. Set up auto-scaling policies

---

## Performance Optimization

### Server Configuration

**For Production:**
- CPU: 4+ cores recommended
- RAM: 8GB minimum, 16GB+ for heavy use
- Storage: SSD for faster I/O

**Shiny Server Settings:**
```nginx
# Increase limits
app_idle_timeout 1800;  # 30 minutes
app_init_timeout 300;   # 5 minutes
simple_scheduler 20;    # Concurrent users
```

### Application Tuning

**In `global.R`:**
```r
# Limit max agents for public deployment
APP_CONFIG$max_agents <- 10000  # Reduce from 50000

# Cache common simulations
# (Implement in Phase 2)
```

**In `app.R`:**
```r
# Add rate limiting
# (Implement in Phase 2)
```

---

## Monitoring

### Logs

**Shiny Server logs:**
```bash
# Application logs
tail -f /var/log/shiny-server/fpsim-shiny-*.log

# Server logs
tail -f /var/log/shiny-server.log
```

### Metrics

Monitor:
- CPU usage
- Memory usage
- Active connections
- Error rates
- Simulation duration

### Tools
- **Grafana + Prometheus:** For metrics visualization
- **CloudWatch:** If using AWS
- **Custom logging:** Add to `global.R`

---

## Security

### Best Practices

1. **Authentication:** Implement user login (Phase 5)
2. **HTTPS:** Use SSL/TLS certificates
3. **Rate Limiting:** Prevent abuse
4. **Input Validation:** Already implemented in app
5. **Firewall:** Restrict access to necessary ports

### SSL Setup (Nginx Reverse Proxy)

```nginx
server {
    listen 443 ssl;
    server_name your-domain.com;
    
    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;
    
    location / {
        proxy_pass http://localhost:3838;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

---

## Troubleshooting

### Common Issues

**App won't start:**
- Check R package installations
- Verify Python environment path
- Review Shiny Server logs

**Simulations timeout:**
- Increase `app_idle_timeout`
- Check server resources
- Reduce max_agents limit

**Python errors:**
- Ensure virtual environment is activated
- Check FPsim installation
- Verify reticulate configuration

---

## Support

For deployment assistance:
- GitHub Issues: https://github.com/fpsim/fpsim/issues
- Documentation: https://docs.fpsim.org
- RStudio Community: https://community.rstudio.com

---

**Version:** 0.1.0  
**Last Updated:** October 10, 2025

