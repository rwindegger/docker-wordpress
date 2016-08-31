FROM php:fpm

# install the PHP extensions we need
RUN apt-get update \
	&& apt-get install -y \
		libpng12-dev \
		libjpeg-dev \
		libmemcached-dev \
		libfreetype6-dev \
    		libmagickwand-dev \
    		--no-install-recommends \
    	&& rm -rf /var/lib/apt/lists/* \
	&& docker-php-ext-configure gd --with-gd --with-freetype-dir=/usr --with-png-dir=/usr --with-jpeg-dir=/usr \
	&& docker-php-ext-install gd mysqli opcache memcache \
	&& docker-php-ext-enable gd \
	&& docker-php-ext-enable opcache \
	&& docker-php-ext-enable memcached \
	&& docker-php-ext-enable memcache \
	&& pecl install imagick \
	&& docker-php-ext-enable imagick \

# set recommended PHP.ini settings
# see https://secure.php.net/manual/en/opcache.installation.php
RUN { \
		echo 'opcache.memory_consumption=128'; \
		echo 'opcache.interned_strings_buffer=8'; \
		echo 'opcache.max_accelerated_files=4000'; \
		echo 'opcache.revalidate_freq=60'; \
		echo 'opcache.fast_shutdown=1'; \
		echo 'opcache.enable_cli=1'; \
	} > /usr/local/etc/php/conf.d/opcache-recommended.ini
	
RUN { \
	echo 'max_input_time = 60'; \
	echo 'max_execution_time = 120'; \
	echo 'upload_max_filesize = 64M'; \
	echo 'post_max_size = 64m'; \
	echo 'memory_limit = 256M'; \
	echo 'expose_php = off'; \
} > /usr/local/etc/php/conf.d/uploadsettings.ini

VOLUME /var/www/html

ENV WORDPRESS_VERSION 4.6
ENV WORDPRESS_SHA1 830962689f350e43cd1a069f3a4f68a44c0339c8

# upstream tarballs include ./wordpress/ so this gives us /usr/src/wordpress
RUN curl -o wordpress.tar.gz -SL https://wordpress.org/wordpress-${WORDPRESS_VERSION}.tar.gz \
	&& echo "$WORDPRESS_SHA1 *wordpress.tar.gz" | sha1sum -c - \
	&& tar -xzf wordpress.tar.gz -C /usr/src/ \
	&& rm wordpress.tar.gz \
	&& chown -R www-data:www-data /usr/src/wordpress

COPY docker-entrypoint.sh /entrypoint.sh

# grr, ENTRYPOINT resets CMD now
ENTRYPOINT ["/entrypoint.sh"]
CMD ["php-fpm"]
