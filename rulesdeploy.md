# Deployment Rules - irvandoda.my.id

## Deployment Overview
Panduan lengkap untuk deploy static website ke server VPS menggunakan Docker + Nginx reverse proxy dengan SSL.

## Prerequisites

### Server Requirements
- Ubuntu 24.04.3 LTS
- Docker v29.2.0+
- Nginx v1.24.0+
- Certbot (Let's Encrypt)
- Minimum 2GB RAM available
- Port 80, 443 terbuka

### Local Requirements
- Git (optional)
- SSH access ke server
- Domain sudah pointing ke server IP

## Deployment Workflow

### 1. Persiapan Project

#### A. Struktur File Minimal
```
project-name/
├── index.html              # Required
├── Dockerfile              # Required
├── docker-compose.yml      # Required
└── assets/                 # Optional
    ├── css/
    ├── js/
    └── images/
```

#### B. Template Dockerfile
```dockerfile
FROM nginx:alpine

COPY . /usr/share/nginx/html

RUN rm -f /usr/share/nginx/html/Dockerfile \
    /usr/share/nginx/html/docker-compose.yml \
    /usr/share/nginx/html/.git -rf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

#### C. Template docker-compose.yml
```yaml
services:
  app:
    build: .
    container_name: <domain>_app
    restart: unless-stopped
    ports:
      - "<port>:80"
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
```

**PENTING**: 
- Ganti `<domain>` dengan nama domain (gunakan underscore, contoh: `irvandoda.my.id_app`)
- Ganti `<port>` dengan port yang belum digunakan (cek port allocation di server.md)

### 2. Port Allocation

#### Cek Port Tersedia
```bash
docker ps --format "table {{.Names}}\t{{.Ports}}" | grep -E ":[0-9]+->80"
```

#### Port Range
- **3000-3999**: Static websites
- **8000-8999**: Dynamic applications
- **9000-9999**: Backend services

#### Next Available Port
Berdasarkan current allocation: **3009**

### 3. Upload ke Server

#### A. Via SCP
```bash
scp -r /local/project/* irvandoda@server:/server/projects/active/<domain>/
```

#### B. Via SFTP
```bash
sftp irvandoda@server
cd /server/projects/active/<domain>
put -r *
```

#### C. Via Git (Recommended)
```bash
# Di server
cd /server/projects/active/
git clone <repository-url> <domain>
cd <domain>
```

### 4. Build & Deploy Container

#### A. Masuk ke Project Directory
```bash
cd /server/projects/active/<domain>
```

#### B. Build Container
```bash
docker-compose build
```

#### C. Start Container
```bash
docker-compose up -d
```

#### D. Verify Container Running
```bash
docker ps | grep <domain>
```

#### E. Test Local Access
```bash
curl http://localhost:<port>
```

### 5. Configure Nginx Reverse Proxy

#### A. Create Nginx Config
```bash
sudo nano /etc/nginx/sites-available/<domain>
```

#### B. Nginx Configuration Template
```nginx
server {
    listen 80;
    listen [::]:80;
    server_name <domain>;
    
    location / {
        proxy_pass http://127.0.0.1:<port>;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_http_version 1.1;
    }
}
```

**Ganti**:
- `<domain>` dengan domain aktual (contoh: `irvandoda.my.id`)
- `<port>` dengan port container (contoh: `3001`)

#### C. Enable Site
```bash
sudo ln -s /etc/nginx/sites-available/<domain> /etc/nginx/sites-enabled/
```

#### D. Test Nginx Config
```bash
sudo nginx -t
```

#### E. Reload Nginx
```bash
sudo systemctl reload nginx
```

### 6. Setup SSL Certificate

#### A. Install Certbot (jika belum)
```bash
sudo apt update
sudo apt install certbot python3-certbot-nginx
```

#### B. Generate SSL Certificate
```bash
sudo certbot --nginx -d <domain>
```

#### C. Verify Auto-Renewal
```bash
sudo certbot renew --dry-run
```

#### D. Check Certificate Status
```bash
sudo certbot certificates
```

### 7. Verification

#### A. Check Container
```bash
docker ps | grep <domain>
docker logs <domain>_app
```

#### B. Check Nginx
```bash
sudo nginx -t
systemctl status nginx
```

#### C. Test HTTP → HTTPS Redirect
```bash
curl -I http://<domain>
```

#### D. Test HTTPS
```bash
curl -I https://<domain>
```

#### E. Browser Test
- Buka `https://<domain>`
- Verify SSL certificate (lock icon)
- Check console untuk errors

## Update Deployment

### Update Content Only

#### A. Stop Container
```bash
cd /server/projects/active/<domain>
docker-compose down
```

#### B. Update Files
```bash
# Upload new files via SCP/SFTP/Git
```

#### C. Rebuild & Restart
```bash
docker-compose up -d --build
```

### Update Configuration

#### A. Edit docker-compose.yml
```bash
nano docker-compose.yml
```

#### B. Recreate Container
```bash
docker-compose down
docker-compose up -d --build
```

### Update Nginx Config

#### A. Edit Config
```bash
sudo nano /etc/nginx/sites-available/<domain>
```

#### B. Test & Reload
```bash
sudo nginx -t
sudo systemctl reload nginx
```

## Rollback Procedure

### Rollback Container

#### A. Stop Current Container
```bash
docker-compose down
```

#### B. Restore Previous Files
```bash
# From backup or git
git checkout <previous-commit>
```

#### C. Rebuild
```bash
docker-compose up -d --build
```

### Rollback Nginx Config

#### A. Restore Config
```bash
sudo cp /etc/nginx/sites-available/<domain>.backup /etc/nginx/sites-available/<domain>
```

#### B. Reload
```bash
sudo nginx -t
sudo systemctl reload nginx
```

## Troubleshooting

### Container Issues

#### Container Won't Start
```bash
# Check logs
docker logs <domain>_app

# Check port conflict
netstat -tulpn | grep <port>

# Rebuild from scratch
docker-compose down
docker system prune -f
docker-compose up -d --build
```

#### Container Keeps Restarting
```bash
# Check logs
docker logs <domain>_app --tail 100

# Check Dockerfile syntax
docker build -t test .

# Check resource limits
docker stats
```

### Nginx Issues

#### 502 Bad Gateway
```bash
# Check container is running
docker ps | grep <domain>

# Check port is correct in nginx config
cat /etc/nginx/sites-available/<domain> | grep proxy_pass

# Test container directly
curl http://localhost:<port>
```

#### 404 Not Found
```bash
# Check nginx config
sudo nginx -t

# Check site is enabled
ls -la /etc/nginx/sites-enabled/ | grep <domain>

# Check nginx logs
tail -f /var/log/nginx/error.log
```

### SSL Issues

#### Certificate Not Valid
```bash
# Renew certificate
sudo certbot renew

# Force renew
sudo certbot renew --force-renewal
```

#### Mixed Content Warnings
```bash
# Ensure all resources use HTTPS
# Check nginx config has X-Forwarded-Proto
```

### Performance Issues

#### High Memory Usage
```bash
# Check container stats
docker stats

# Restart container
docker-compose restart

# Check system resources
free -h
```

#### Slow Response
```bash
# Check nginx logs
tail -f /var/log/nginx/access.log

# Check container logs
docker logs <domain>_app --tail 100

# Test direct container access
curl -w "@curl-format.txt" http://localhost:<port>
```

## Best Practices

### Security
- ✅ Always use HTTPS
- ✅ Keep Docker & Nginx updated
- ✅ Use minimal base images (Alpine)
- ✅ Remove unnecessary files from container
- ✅ Regular security audits
- ✅ Backup SSL certificates

### Performance
- ✅ Enable gzip compression
- ✅ Use HTTP/2
- ✅ Optimize images
- ✅ Minimize CSS/JS
- ✅ Use CDN for static assets
- ✅ Enable browser caching

### Maintenance
- ✅ Regular backups
- ✅ Monitor disk space
- ✅ Monitor container health
- ✅ Clean unused Docker images
- ✅ Review logs regularly
- ✅ Document changes

### Development Workflow
- ✅ Test locally first
- ✅ Use version control (Git)
- ✅ Staging environment before production
- ✅ Backup before updates
- ✅ Rollback plan ready
- ✅ Monitor after deployment

## Maintenance Commands

### Docker Cleanup
```bash
# Remove unused containers
docker container prune -f

# Remove unused images
docker image prune -a -f

# Remove unused networks
docker network prune -f

# Full cleanup
docker system prune -a -f
```

### Nginx Maintenance
```bash
# Reload config
sudo systemctl reload nginx

# Restart service
sudo systemctl restart nginx

# Check logs
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log

# Rotate logs
sudo logrotate -f /etc/logrotate.d/nginx
```

### SSL Maintenance
```bash
# Check expiry
sudo certbot certificates

# Renew all
sudo certbot renew

# Test renewal
sudo certbot renew --dry-run
```

## Quick Reference

### Common Commands
```bash
# Deploy new site
cd /server/projects/active/<domain>
docker-compose up -d --build

# Update existing site
docker-compose down
docker-compose up -d --build

# Check status
docker ps | grep <domain>

# View logs
docker logs <domain>_app -f

# Restart container
docker-compose restart

# Stop container
docker-compose down

# Remove container
docker-compose down -v
```

### Port Allocation Checklist
- [ ] Check available port
- [ ] Update docker-compose.yml
- [ ] Update nginx config
- [ ] Test locally
- [ ] Document in server.md

### Deployment Checklist
- [ ] Files uploaded
- [ ] Dockerfile configured
- [ ] docker-compose.yml configured
- [ ] Container built & running
- [ ] Nginx config created
- [ ] Nginx config enabled
- [ ] Nginx reloaded
- [ ] SSL certificate generated
- [ ] HTTP → HTTPS redirect working
- [ ] Website accessible
- [ ] SSL valid
- [ ] Logs checked
- [ ] Documentation updated

## Emergency Contacts
- **Server Admin**: irvandoda
- **Server**: vmi2351680
- **Documentation**: /server/projects/active/<domain>/server.md
