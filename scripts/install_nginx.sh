#!/bin/bash
sudo amazon-linux-extras install -y nginx1
sudo su -c \"echo "user nginx;
worker_processes auto;

error_log /var/log/nginx/error.log;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';

    access_log /var/log/nginx/access.log main;

    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;
    
    # this the custom configuration to forward the traffic from proxy to the private load balancer
    server {
        listen 80;
        listen [::]:80;
        server_name $1;
        location / {
            proxy_pass $1;
        }
    }
}" > /etc/nginx/nginx.conf\"
sudo systemctl start nginx
sudo systemctl enable nginx