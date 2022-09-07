FROM php:8.1-apache
EXPOSE 80/tcp
COPY ./phpinfo.php /var/www/html/info.php