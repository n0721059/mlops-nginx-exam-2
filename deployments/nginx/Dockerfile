FROM nginx:1.27

COPY nginx.conf /etc/nginx/nginx.conf

# Basic-auth user file (admin:admin) for /predict endpoint.
COPY .htpasswd /etc/nginx/.htpasswd

# Self-signed TLS cert 
COPY certs/ /etc/nginx/certs/

# container listens on 80 & 443, the gateway serves (HTTP redirect + HTTPS).
EXPOSE 80 443
