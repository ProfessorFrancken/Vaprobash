#!/usr/bin/env bash

export LANG=C.UTF-8

PHP_TIMEZONE=$1
PHP_VERSION=$2

echo ">>> Installing PHP $PHP_VERSION"

sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C

sudo apt-key update
sudo apt-get update

# Install PHP
# -qq implies -y --force-yes
sudo apt-get install -qq php7.0-cli php7.0-fpm php7.0-mysql php7.0-pgsql php7.0-sqlite php7.0-curl php7.0-gd php7.0-gmp php7.0-mcrypt php7.0-memcached php7.0-imagick php7.0-intl php7.0-xdebug

# Set PHP FPM to listen on TCP instead of Socket
sudo sed -i "s/listen =.*/listen = 127.0.0.1:9000/" /etc/php/7.0/fpm/pool.d/www.conf

# Set PHP FPM allowed clients IP address
sudo sed -i "s/;listen.allowed_clients/listen.allowed_clients/" /etc/php/7.0/fpm/pool.d/www.conf

# Set run-as user for PHP7.0-FPM processes to user/group "vagrant"
# to avoid permission errors from apps writing to files
sudo sed -i "s/user = www-data/user = vagrant/" /etc/php/7.0/fpm/pool.d/www.conf
sudo sed -i "s/group = www-data/group = vagrant/" /etc/php/7.0/fpm/pool.d/www.conf

sudo sed -i "s/listen\.owner.*/listen.owner = vagrant/" /etc/php/7.0/fpm/pool.d/www.conf
sudo sed -i "s/listen\.group.*/listen.group = vagrant/" /etc/php/7.0/fpm/pool.d/www.conf
sudo sed -i "s/listen\.mode.*/listen.mode = 0666/" /etc/php/7.0/fpm/pool.d/www.conf


# xdebug Config
cat > $(find /etc/php7.0 -name xdebug.ini) << EOF
zend_extension=$(find /usr/lib/php7.0 -name xdebug.so)
xdebug.remote_enable = 1
xdebug.remote_connect_back = 1
xdebug.remote_port = 9000
xdebug.scream=0
xdebug.cli_color=1
xdebug.show_local_vars=1

; var_dump display
xdebug.var_display_max_depth = 5
xdebug.var_display_max_children = 256
xdebug.var_display_max_data = 1024
EOF

# PHP Error Reporting Config
sudo sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.0/fpm/php.ini
sudo sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.0/fpm/php.ini

# PHP Date Timezone
sudo sed -i "s/;date.timezone =.*/date.timezone = ${PHP_TIMEZONE/\//\\/}/" /etc/php/7.0/fpm/php.ini
sudo sed -i "s/;date.timezone =.*/date.timezone = ${PHP_TIMEZONE/\//\\/}/" /etc/php/7.0/cli/php.ini

sudo service php7.0-fpm restart
