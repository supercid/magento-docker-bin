#!/bin/bash

set -e

bin/removeall

rm -rf src

bin/download 2.4.7 community
bin/setup magento245.dev.nos.to:8443

bin/magento module:disable Magento_AdminAdobeImsTwoFactorAuth
bin/magento module:disable Magento_TwoFactorAuth
bin/magento config:set admin/security/session_lifetime 31536000
# bin/magento module:disable Magento_Csp --clear-static-content

bin/composer config minimum-stability dev
bin/composer config --unset repositories.0

# bin/composer require --no-update nosto/module-nostotagging:"@stable" 
# bin/composer update --no-dev

bin/composer require --no-update nosto/module-nostotagging:"@stable"
bin/composer require --no-update nosto/module-nostotagging-cmp:"@stable"
bin/composer require --no-update nosto/module-nosto-msi:"@stable"

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
bin/magento config:set nosto_cmp/flags/category_sorting 1
bin/magento config:set nosto_cmp/flags/map_all_categories 1
bin/magento cache:flush


bin/magento module:enable --clear-static-content Nosto_Tagging Nosto_Cmp Nosto_Msi
bin/magento setup:upgrade
bin/magento setup:di:compile
bin/magento setup:static-content:deploy -f
bin/magento cache:clean

bin/copyfromcontainer vendor/nosto
# cp env/nosto.env src/vendor/nosto/php-sdk/src/.env
# bin/copytocontainer vendor/nosto/php-sdk/src/

# If you're doing local development, this sets up the git repositories:
rm -rf src/vendor/nosto/module-nostotagging
rm -rf src/vendor/nosto/module-nostotagging-cmp
rm -rf src/vendor/nosto/module-nosto-msi
rm -rf src/vendor/nosto/php-sdk
git clone git@github.com:Nosto/nosto-magento2.git src/vendor/nosto/module-nostotagging
git clone git@github.com:Nosto/nosto-magento2-cmp.git src/vendor/nosto/module-nostotagging-cmp
git clone git@github.com:Nosto/nosto-magento2-msi.git src/vendor/nosto/module-nosto-msi
git clone git@github.com:Nosto/nosto-php-sdk.git src/vendor/nosto/php-sdk
cp env/nosto.env src/vendor/nosto/php-sdk/src/.env
bin/copytocontainer vendor/nosto
bin/magento module:enable --clear-static-content Nosto_Tagging Nosto_Cmp Nosto_Msi
bin/magento setup:upgrade
bin/magento setup:di:compile
bin/magento setup:static-content:deploy -f
bin/magento cache:clean
echo "You should be set for local development. Remember to add magento src to PHPStorm for code completion and uncomment the plugins path from the composer file"