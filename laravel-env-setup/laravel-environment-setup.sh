#!/usr/bin/env bash
set -euo pipefail

### ------ config ------ ###
PHP_VERSION="8.4"
PHP_EXTS=(fpm cli xml mbstring zip bcmath curl pgsql)
INSTALL_NODE=true
### ------ config ------ ###

echo ">>> Updating system"
sudo apt-get update -y
sudo apt-get upgrade -y -N

if [[ "$INSTALL_NODE" == true ]]; then
  echo ">>> Installing Node.js (stable)"
  sudo apt-get install -y npm
  sudo npm install -g n
  sudo n stable
fi

echo ">>> Installing PHP ${PHP_VERSION} and extensions"
sudo apt-get install -y software-properties-common ca-certificates gnupg curl
sudo add-apt-repository -y ppa:ondrej/php
sudo apt-get update -y

# build package list from array
PKGS=("php${PHP_VERSION}")
for ext in "${PHP_EXTS[@]}"; do
  PKGS+=("php${PHP_VERSION}-${ext}")
done
sudo apt-get install -y "${PKGS[@]}"

echo ">>> PHP installed:"
php -v
echo ">>> Extensions:"
php -m | sort
echo "PHP-FPM socket should be: /run/php/php${PHP_VERSION}-fpm.sock"

echo ">>> Installing Composer"
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384','composer-setup.php') === 'ed0feb545ba87161262f2d45a633e34f591ebb3381f2e0063c345ebea4d228dd0043083717770234ec00c5a9f9593792') { echo 'Installer verified'.PHP_EOL; } else { echo 'Installer corrupt'.PHP_EOL; unlink('composer-setup.php'); exit(1); }"
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
php -r "unlink('composer-setup.php');"

echo ">>> Composer version:"
composer --version
echo "Setup completed successfully"
