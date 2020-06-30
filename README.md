# Intro
Follow Magento official guide from https://devdocs.magento.com/guides/v2.4/install-gde/install-roadmap_part1.html
Based on Ubuntu 20.4. Installed Magento 2.3.4p1, MariaDB 10.3.22, PHP 7.3, Nginx 1.18. And some common development tools like curl,wget,unzip,git,telnet,openjdk-8-jdk.

# How to pull
    docker pull wyw656141/magento2devbox

# How to run
    docker run -it -dp 80:80 wyw656141/magento2devbox
    docker attach <container id>
    service mysql start
    service php7.3-fpm start
    service nginx start

# Import sample data
    bin/magento sampledata:deploy
    bin/magento setup:upgrade  

# Important file directory
Nginx config /etc/nginx/sites-available/magento
Nginx root /var/www/html
Magento /var/www/html/magento2

# Useful commands
https://devdocs.magento.com/guides/v2.4/install-gde/install/cli/install-cli-subcommands.html

    bin/magento setup:install
    bin/magento setup:upgrade 
    bin/magento setup:di:compile
    bin/magento setup:static-content:deploy -f
    bin/magento cache:clean
    bin/magento cache:flush
