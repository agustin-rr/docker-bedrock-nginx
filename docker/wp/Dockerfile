# Use this when Dockerfile has changed:
#   $ docker-compose up --force-recreate --build

ARG version=7.4

# https://hub.docker.com/_/php
FROM php:${version}-fpm-alpine


# ------------------------------------------------------------------------------------
# Install dependencies. Based on:
# https://github.com/docker-library/wordpress/blob/97f75b51f909fbd9894d128ea6893120cfd23979/latest/php7.4/fpm-alpine/Dockerfile

# persistent dependencies
RUN set -eux; \
	apk add --no-cache \
# in theory, docker-entrypoint.sh is POSIX-compliant, but priority is a working, consistent image
		bash \
# Ghostscript is required for rendering PDF previews
		ghostscript \
# Alpine package for "imagemagick" contains ~120 .so files, see: https://github.com/docker-library/wordpress/pull/497
		imagemagick \
	;

# install the PHP extensions we need (https://make.wordpress.org/hosting/handbook/handbook/server-environment/#php-extensions)
RUN set -ex; \
	\
	apk add --no-cache --virtual .build-deps \
		$PHPIZE_DEPS \
		freetype-dev \
		icu-dev \
		imagemagick-dev \
		libjpeg-turbo-dev \
		libpng-dev \
		libwebp-dev \
		libzip-dev \
		# Custom dependencies.
		libxml2-dev \
		curl-dev \
		gettext-dev \
	; \
	\
	docker-php-ext-configure gd \
		--with-freetype \
		--with-jpeg \
		--with-webp \
	; \
	docker-php-ext-install -j "$(nproc)" \
		bcmath \
		exif \
		gd \
		intl \
		mysqli \
		zip \
		# Custom dependencies. Already installed: mbstring
		pdo \
		pdo_mysql \
		xml \
		curl \
		gettext \
	; \
# WARNING: imagick is likely not supported on Alpine: https://github.com/Imagick/imagick/issues/328
# https://pecl.php.net/package/imagick
	pecl install imagick-3.6.0; \
	docker-php-ext-enable imagick; \
	rm -r /tmp/pear; \
	\
# some misbehaving extensions end up outputting to stdout 🙈 (https://github.com/docker-library/wordpress/issues/669#issuecomment-993945967)
	out="$(php -r 'exit(0);')"; \
	[ -z "$out" ]; \
	err="$(php -r 'exit(0);' 3>&1 1>&2 2>&3)"; \
	[ -z "$err" ]; \
	\
	extDir="$(php -r 'echo ini_get("extension_dir");')"; \
	[ -d "$extDir" ]; \
	runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive "$extDir" \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)"; \
	apk add --no-network --virtual .wordpress-phpexts-rundeps $runDeps; \
	apk del --no-network .build-deps; \
	\
	! { ldd "$extDir"/*.so | grep 'not found'; }; \
# check for output like "PHP Warning:  PHP Startup: Unable to load dynamic library 'foo' (tried: ...)
	err="$(php --version 3>&1 1>&2 2>&3)"; \
	[ -z "$err" ]
# ------------------------------------------------------------------------------------

# OPCache
RUN docker-php-ext-enable opcache
COPY ./php/opcache.ini /usr/local/etc/php/conf.d/

# Debug (error logging)
COPY ./php/debug.ini /usr/local/etc/php/conf.d/

# Xdebug for PHP 8
# RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
#     && apk add --update linux-headers \
#     && pecl install xdebug \
#     && docker-php-ext-enable xdebug \
#     && apk del -f .build-deps
# COPY ./php/xdebug-php8.ini /usr/local/etc/php/conf.d/

# or Xdebug for PHP 7.4
RUN apk add --no-cache $PHPIZE_DEPS \
    && pecl install xdebug-2.9.2 \
    && docker-php-ext-enable xdebug
COPY ./php/xdebug-php7.ini /usr/local/etc/php/conf.d/xdebug.ini.new
RUN cat /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini >> /usr/local/etc/php/conf.d/xdebug.ini.new \
    && mv /usr/local/etc/php/conf.d/xdebug.ini.new /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# MailHog
COPY ./php/mail-hog.ini /usr/local/etc/php/conf.d/

# Update UID and GID of www-data
ARG uid
ARG gid
RUN apk --no-cache add shadow && \
    usermod -u $uid www-data && \
    groupmod -g $gid www-data


# Install wp-cli
# PAGER avoid error: "less: unrecognized option: r" in help command
ENV PAGER='more'
RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x /usr/local/bin/wp && \
    mkdir -p /var/www/.wp-cli/cache && chown www-data:www-data /var/www/.wp-cli/cache

# Forward Message to mailhog
# RUN curl --location --output /usr/local/bin/mhsendmail https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64 && \
#     chmod +x /usr/local/bin/mhsendmail
# RUN echo 'sendmail_path="/usr/local/bin/mhsendmail --smtp-addr=mailhog:1025 --from=no-reply@gbp.lo"' > /usr/local/etc/php/conf.d/mailhog.ini

# Composer
RUN curl -sS https://getcomposer.org/installer | php -- --version=2.4.4 --install-dir=/usr/local/bin --filename=composer

# Install PHPUnit
# RUN wget -O phpunit https://phar.phpunit.de/phpunit-9.phar && chmod +x phpunit && mv phpunit /usr/local/bin/phpunit

# Show versions
RUN php -v &&  \
    wp --allow-root --version &&  \
    composer --version
#    # phpunit --version


VOLUME /var/www/html

COPY ./bedrock-entrypoint.sh /usr/local/bin/
RUN chmod 775 /usr/local/bin/bedrock-entrypoint.sh
ENTRYPOINT ["bedrock-entrypoint.sh"]

CMD ["php-fpm"]

