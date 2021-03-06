#!/bin/bash

set -e

docker-compose down -v --remove-orphans

rm -rf src

bin/download 2.4.4
bin/setup magento2.dev.nos.to:8443

bin/magento module:disable Magento_TwoFactorAuth
# bin/magento module:disable Magento_Csp --clear-static-content

bin/composer config minimum-stability dev
bin/composer config --unset repositories.0

# bin/composer require --no-update nosto/module-nostotagging:"@stable" 
# bin/composer update --no-dev

bin/composer require --no-update nosto/module-nostotagging:dev-feature/2.4.4-compatibility
# composer require --no-update nosto/module-nostotagging-cmp:dev-develop
# composer require --no-update nosto/module-nosto-msi:@stable

bin/composer config repositories.0 '{"type": "composer", "url": "https://repo.magento.com", "exclude": ["nosto/*"]}'
bin/composer update --no-dev

bin/magento sampledata:deploy
bin/magento setup:upgrade


bin/magento config:set nosto/flags/inventory_tagging 1
bin/magento config:set nosto/flags/variation_tagging 1
bin/magento config:set nosto/flags/use_custom_fields 1
bin/magento config:set nosto/flags/altimg_tagging 1
bin/magento config:set nosto/flags/rating_tagging 1
bin/magento config:set nosto/flags/product_updates 1
bin/magento config:set nosto/flags/low_stock_indication 1
bin/magento config:set nosto/flags/send_customer_data 1
bin/magento config:set nosto/flags/indexer_memory 70
bin/magento config:set nosto/flags/tag_date_published 1
# bin/magento config:set nosto_cmp/flags/category_sorting 1
# bin/magento config:set nosto_cmp/flags/map_all_categories 1
# bin/magento cache:flush


bin/magento module:enable --clear-static-content Nosto_Tagging
bin/magento setup:upgrade
bin/magento setup:di:compile
bin/magento setup:static-content:deploy -f
bin/magento cache:clean

cp env/nosto.env src/vendor/nosto/php-sdk/src/.env
bin/copytocontainer vendor/nosto/php-sdk/src/

# Uncoment if you're doing local development, this sets up the git repo:
# git clone git@github.com:Nosto/nosto-magento2.git src/vendor/nosto/module-nostotagging
# git clone git@github.com:Nosto/nosto-magento2-cmp.git src/vendor/nosto/module-nostotagging-cmp
# bin/copytocontainer vendor/nosto
# bin/magento module:enable --clear-static-content Nosto_Tagging Nosto_Cmp
# bin/magento setup:upgrade
# bin/magento setup:di:compile
# bin/magento setup:static-content:deploy -f
# bin/magento cache:clean
# echo "You should be set for local development. Remember to add magento src to PHPStorm for code completion"