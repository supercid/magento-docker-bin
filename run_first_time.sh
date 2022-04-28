#!/bin/bash

set -e

docker-compose down -v --remove-orphans

rm -rf src

bin/download 2.4.4
bin/setup magento.dev.nos.to:8443

bin/magento sampledata:deploy
bin/magento setup:upgrade

bin/composer remove magento/composer-dependency-version-audit-plugin
bin/magento module:disable Magento_TwoFactorAuth
bin/magento cache:flush

bin/composer require --no-update nosto/module-nostotagging:"@stable" && bin/composer update --no-dev
bin/magento module:enable --clear-static-content Nosto_Tagging; bin/magento setup:upgrade; bin/magento setup:di:compile; bin/magento setup:static-content:deploy; bin/magento cache:clean