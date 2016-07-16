FROM wordpress:fpm

RUN apt-get update && apt-get install -y libmemcached-dev libfreetype6-dev \
    && pecl install memcached \
    && pecl install memcache \
    && docker-php-ext-configure gd --with-freetype-dir=/usr \
    && docker-php-ext-install gd \
    && docker-php-ext-enable gd \
    && docker-php-ext-enable memcached \
    && docker-php-ext-enable memcache

# grr, ENTRYPOINT resets CMD now
ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]
