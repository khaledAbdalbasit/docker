
# Stage 1: Build the PHP environment and install Composer dependencies.
FROM php:8.4-fpm AS builder
# Install system libraries and compile the required PHP extensions.
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    unzip \
    libzip-dev \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        zip \
        bcmath \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set the working directory inside the container.
WORKDIR /var/www

# Copy the Laravel application source code.
COPY . /var/www

# Copy Composer from its official image.
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Install production dependencies and optimize the autoloader.
RUN composer install \
    --no-dev \
    --optimize-autoloader \
    --no-interaction \
    --no-progress \
    --prefer-dist


# Stage 2: Production environment.
FROM php:8.4-fpm AS production
# Copy the container startup script.
COPY ./docker/production/php-fpm/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Run the entrypoint when the container starts.
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

RUN apt-get update && apt-get install -y --no-install-recommends \
    libfcgi-bin \
    procps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --from=builder /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/
COPY --from=builder /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/
COPY --from=builder /usr/local/bin/docker-php-ext-* /usr/local/bin/

RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
COPY ./docker/production/php-fpm/php.ini $PHP_INI_DIR/conf.d/99-production.ini

COPY ./docker/common/php-fpm/conf.d/*.conf /usr/local/etc/php-fpm.d/

COPY --from=builder /var/www /var/www

WORKDIR /var/www

# Copy the initial storage structure for container startup.
COPY ./storage /var/www/storage-init

RUN chown -R www-data:www-data /var/www

USER www-data

EXPOSE 9000
CMD ["php-fpm"]
