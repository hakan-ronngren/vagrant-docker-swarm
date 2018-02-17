FROM php:7.0-apache

# Create an auto-refreshing page that displays the docker hostname
# of the container that rendered it.
RUN mkdir -p /var/www/html && echo '<? header("Connection: close"); ?><html><head><meta http-equiv="Refresh" content="2"></head><body><h1>It works on <?= php_uname("n"); ?></h1></body></html>' > /var/www/html/index.php
