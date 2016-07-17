FROM wordpress:fpm

RUN apt-get update && apt-get install -y libmemcached-dev libfreetype6-dev \
    libmagickwand-dev --no-install-recommends \
    && pecl install memcached \
    && pecl install memcache \
    && docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr --with-png-dir=/usr --with-jpeg-dir=/usr \
    && docker-php-ext-enable gd \
    && docker-php-ext-enable memcached \
    && docker-php-ext-enable memcache \
    && pecl install imagick \
    && docker-php-ext-enable imagick \
    && rm -r /var/lib/apt/lists/*

RUN { \
	echo 'max_input_time = 60'; \
	echo 'max_execution_time = 120'; \
	echo 'upload_max_filesize = 64M'; \
	echo 'post_max_size = 64m'; \
	echo 'memory_limit = 256M'; \
	echo 'expose_php = off'; \
} > /usr/local/etc/php/conf.d/uploadsettings.ini

# grr, ENTRYPOINT resets CMD now
ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]
