# ============================================================================
# Portfolio React + Vite — Nginx Alpine
# ============================================================================
FROM nginx:alpine

# Copy built static files from dist folder
COPY dist/ /usr/share/nginx/html/

# Copy LP folder for landing pages
COPY LP/ /usr/share/nginx/html/LP/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
