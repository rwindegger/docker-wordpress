FROM wordpress:fpm

RUN apt-get update && apt-get install -y libmemcached-dev \
    && pecl install memcached \
    && pecl install memcache \
    && docker-php-ext-enable memcached \
    && docker-php-ext-enable memcache

# grr, ENTRYPOINT resets CMD now
ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]
