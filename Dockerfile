FROM php:7.4-fpm-alpine

ENV GITHUB_USER
ENV GITHUB_TOKEN

WORKDIR /app

RUN apk add --no-cache --update ca-certificates dcron curl git supervisor tar unzip nginx libpng-dev libxml2-dev libzip-dev unzip \
    && docker-php-ext-configure zip \
    && docker-php-ext-install bcmath gd pdo_mysql zip json xml curl

# Install ioncube
RUN curl -o ioncube.tar.gz http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz \
    && tar -xvvzf ioncube.tar.gz \
    && mv ioncube/ioncube_loader_lin_7.4.so `php-config --extension-dir` \
    && rm -Rf ioncube.tar.gz ioncube \
    && docker-php-ext-enable ioncube_loader_lin_7.4

RUN curl -o whmcs.zip https://skynode-whmcs-docker.eu-central-1.linodeobjects.com/whmcs.zip \
    && unzip whmcs.zip "whmcs/*" -d . \
    && php -f install/bin/installer.php –- -u -n \
    && rm -rf install \
    && mv admin snstaff \
    && chown -R nginx:nginx .

RUN rm /usr/local/etc/php-fpm.conf \
    && sed -i s/ssl_session_cache/#ssl_session_cache/g /etc/nginx/nginx.conf \
    && mkdir -p /var/run/php /var/run/nginx

COPY .github/docker/default.conf /etc/nginx/http.d/default.conf
COPY .github/docker/www.conf /usr/local/etc/php-fpm.conf
COPY .github/docker/supervisord.conf /etc/supervisord.conf

EXPOSE 80
ENTRYPOINT [ "/bin/ash", ".github/docker/entrypoint.sh" ]
CMD [ "supervisord", "-n", "-c", "/etc/supervisord.conf" ]