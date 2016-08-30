#!/usr/bin/env bash

# Test if PHP is installed
php -v > /dev/null 2>&1
PHP_IS_INSTALLED=$?

[[ $PHP_IS_INSTALLED -ne 0 ]] && { printf "!!! PHP is not installed.\n    Installing Composer aborted!\n"; exit 0; }

# Test if Composer is installed
composer -v > /dev/null 2>&1
COMPOSER_IS_INSTALLED=$?

# Getting the arguments
GITHUB_OAUTH=$1

# True, if composer is not installed
if [[ $COMPOSER_IS_INSTALLED -ne 0 ]]; then
    echo ">>> Installing Composer"
    # Install Composer
    curl -sS https://getcomposer.org/installer | php
    sudo mv composer.phar /usr/local/bin/composer
else
    echo ">>> Updating Composer"
    composer self-update
fi

if [[ $GITHUB_OAUTH != "" ]]; then
    if [[ ! $COMPOSER_IS_INSTALLED -eq 1 ]]; then
        echo ">>> Setting Github Personal Access Token"
        composer config -g github-oauth.github.com $GITHUB_OAUTH
    fi
fi
