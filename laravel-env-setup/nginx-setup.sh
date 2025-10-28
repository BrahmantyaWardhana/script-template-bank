#!/usr/bin/env bash

set -euo pipefail

### ------ config ------ ###
APP_NAME="website-name"
SERVER_NAME="server_ip_or_domain"
PHP_SOCK="/run/php/php8.2-fpm.sock"
### ------ config ------ ###

sudo apt install -y nginx
sudo systemctl enable nginx

sudo mkdir /var/www/"${APP_NAME}"

# nginx server config

sudo tee /etc/nginx/sites-available/"${APP_NAME}" >/dev/null <<CONF
server {
    listen 80;
    listen [::]:80;
    server_name ${SERVER_NAME};
    root /var/www/${APP_NAME}/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";
    index index.php;
    charset utf-8;

    location / { try_files \$uri \$uri/ /index.php?\$query_string; }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ ^/index\.php(/|$) {
        fastcgi_pass unix:${PHP_SOCK};
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
        fastcgi_hide_header X-Powered-By;
    }

    location ~ /\. { deny all; }
}
CONF

# enable app

sudo ln -s /etc/nginx/sites-available/"${APP_NAME}" /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl reload nginx