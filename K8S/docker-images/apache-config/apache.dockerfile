FROM php:8.1-apache
EXPOSE 80/tcp
RUN rm /etc/apache2/ports.conf
COPY ./phpinfo.php /var/www/html/info.php