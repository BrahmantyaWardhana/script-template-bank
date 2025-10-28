#!/usr/bin/env bash
set -euo pipefail

### ------ config ------ ###
APP_NAME="website-name"
REPO_LOCAL_DIR="${HOME}/websote-repo"
### ------ config ------ ###

# move app to /var/www/

sudo mkdir /var/www/"${APP_NAME}"
sudo cp -a "$REPO_LOCAL_DIR" /var/www/"${APP_NAME}"/

# give app write perms

sudo chown -R www-data:www-data /var/www/"${APP_NAME}"/storage
sudo chown -R www-data:www-data /var/www/"${APP_NAME}"/bootstrap/cache

# build app

cd /var/www/"${APP_NAME}"
sudo chown -R $USER:$USER .

cp .env.example .env
composer install --no-dev --optimize-autoloader
php artisan key:generate
php artisan migrate:fresh --seed

# Final perms for Laravel
sudo chown -R www-data:www-data storage bootstrap/cache
sudo find storage bootstrap/cache -type d -exec chmod 775 {} \;
sudo find storage bootstrap/cache -type f -exec chmod 664 {} \;

sudo systemctl reload nginx