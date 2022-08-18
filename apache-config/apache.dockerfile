FROM php:8.1-apache
EXPOSE 8080/tcp
RUN echo "Listen 8088" > /etc/apache2/ports.conf
COPY ./phpinfo.php /var/www/html/info.php