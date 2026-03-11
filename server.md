# Server Documentation - irvandoda.my.id

## Server Overview
VPS hosting untuk multiple static websites menggunakan Docker + Nginx reverse proxy dengan SSL/TLS.

## Server Specifications

### Hardware & OS
- **OS**: Ubuntu 24.04.3 LTS (Noble Numbat)
- **CPU**: 4 cores
- **RAM**: 5.8 GB (Currently used: 5.6 GB)
- **Swap**: 4.0 GB (Currently used: 3.3 GB)
- **Storage**: 96 GB (Used: 27 GB, Available: 70 GB)

### Software Stack
- **Docker**: v29.2.0
- **Nginx**: v1.24.0 (Ubuntu)
- **SSL/TLS**: Let's Encrypt (Certbot)
- **Shell**: Bash

## Architecture

### System Design
```
Internet
    ↓
Nginx (Host) :80/:443
    ↓ (Reverse Proxy)
Docker Containers
    ├── irvandoda.my.id_app → :3001
    ├── borneokreasisejahtera.web.id_app → :3000
    ├── bpjskesehatan.my.id_app → :3002
    ├── crowndeliverylangsa.web.id_app → :3003
    ├── daskhabeauty.web.id_app → :3004
    ├── familytravelgroup.web.id_app → :3005
    ├── jasaangkutansampahpontianak.web.id_app → :3006
    ├── kucingmania.my.id_app → :3007
    └── layananwifimyrepublic.web.id_app → :3008
```

### Container Architecture
- **Base Image**: nginx:alpine
- **Network**: Bridge (isolated per project)
- **Restart Policy**: unless-stopped
- **Port Mapping**: Host port → Container :80

## Directory Structure

```
/server/projects/
├── active/              → Production websites
│   ├── irvandoda.my.id/
│   ├── antonfreezerjaya.com/
│   ├── borneokreasisejahtera.web.id/
│   └── [22+ other domains]
├── staging/             → Testing environment
└── archive/             → Archived projects
```

### Project Structure (irvandoda.my.id)
```
/server/projects/active/irvandoda.my.id/
├── index.html           → Static HTML content
├── Dockerfile           → Container build config
├── docker-compose.yml   → Container orchestration
├── server.md            → This documentation
└── rulesdeploy.md       → Deployment guide
```

## Network Configuration

### Docker Networks
Setiap project memiliki isolated bridge network:
- `irvandodamyid_app-network`
- `borneokreasisejahterawebid_app-network`
- `bpjskesehatanmyid_app-network`
- Dan seterusnya...

### Port Allocation
| Domain | Container Port | Status |
|--------|---------------|--------|
| borneokreasisejahtera.web.id | 3000 | Running |
| irvandoda.my.id | 3001 | Running |
| bpjskesehatan.my.id | 3002 | Running |
| crowndeliverylangsa.web.id | 3003 | Running |
| daskhabeauty.web.id | 3004 | Running |
| familytravelgroup.web.id | 3005 | Running |
| jasaangkutansampahpontianak.web.id | 3006 | Running |
| kucingmania.my.id | 3007 | Running |
| layananwifimyrepublic.web.id | 3008 | Running |

## Nginx Configuration

### Reverse Proxy Setup
Location: `/etc/nginx/sites-available/irvandoda.my.id`

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name irvandoda.my.id;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name irvandoda.my.id;

    ssl_certificate /etc/letsencrypt/live/irvandoda.my.id/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/irvandoda.my.id/privkey.pem;

    location / {
        proxy_pass http://127.0.0.1:3001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_http_version 1.1;
    }
}
```

### SSL/TLS
- **Provider**: Let's Encrypt
- **Management**: Certbot (auto-renewal)
- **Protocol**: HTTP/2
- **Redirect**: HTTP → HTTPS (301)

## Docker Configuration

### Dockerfile
```dockerfile
FROM nginx:alpine
COPY . /usr/share/nginx/html
RUN rm -f /usr/share/nginx/html/Dockerfile \
    /usr/share/nginx/html/docker-compose.yml \
    /usr/share/nginx/html/.git -rf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### docker-compose.yml
```yaml
services:
  app:
    build: .
    container_name: irvandoda.my.id_app
    restart: unless-stopped
    ports:
      - "3001:80"
    networks:
      - app-network

networks:
  app-network:
    driver: bridge
```

## Active Domains
Total: 23+ domains aktif di server ini

### Verified Active
1. antonfreezerjaya.com (Port 8001)
2. borneokreasisejahtera.web.id (Port 3000)
3. bpjskesehatan.my.id (Port 3002)
4. crowndeliverylangsa.web.id (Port 3003)
5. daskhabeauty.web.id (Port 3004)
6. familytravelgroup.web.id (Port 3005)
7. irvandoda.my.id (Port 3001)
8. jasaangkutansampahpontianak.web.id (Port 3006)
9. kucingmania.my.id (Port 3007)
10. layananwifimyrepublic.web.id (Port 3008)

## Monitoring & Maintenance

### Check Container Status
```bash
docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

### Check Nginx Status
```bash
systemctl status nginx
```

### Check Resource Usage
```bash
free -h          # Memory
df -h            # Disk
docker stats     # Container resources
```

### Check Logs
```bash
# Container logs
docker logs irvandoda.my.id_app

# Nginx logs
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
```

## Security

### SSL/TLS
- Auto-renewal via Certbot
- Strong cipher suites
- HTTP/2 enabled
- HTTPS redirect enforced

### Container Isolation
- Separate bridge networks per project
- No direct container-to-container communication
- Host firewall rules

### Best Practices
- Regular security updates
- Minimal container images (Alpine)
- No unnecessary services
- Automated SSL renewal

## Performance Optimization

### Nginx
- HTTP/2 enabled
- Gzip compression
- Static file caching
- Connection pooling

### Docker
- Alpine-based images (minimal size)
- Multi-stage builds
- Resource limits per container
- Restart policy: unless-stopped

## Backup Strategy
- Regular snapshots of `/server/projects/`
- SSL certificates backup
- Nginx configuration backup
- Docker volume backups

## Troubleshooting

### Container Won't Start
```bash
docker logs <container_name>
docker-compose down && docker-compose up -d --build
```

### Nginx Issues
```bash
nginx -t                    # Test config
systemctl restart nginx     # Restart service
```

### SSL Certificate Issues
```bash
certbot renew --dry-run
certbot certificates
```

### Port Conflicts
```bash
netstat -tulpn | grep :<port>
docker ps | grep <port>
```

## Contact & Access
- **Server**: vmi2351680
- **User**: irvandoda
- **Project Path**: /server/projects/active/irvandoda.my.id
