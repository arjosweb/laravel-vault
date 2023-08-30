FROM php:8.2-fpm-alpine

# Instala as dependências para compilar extensões PHP
RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
    pcre-dev \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && apk del .build-deps

# Instala o Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Instala a extensão pdo_mysql
RUN docker-php-ext-install pdo_mysql

# Cria o diretório de logs e define permissões
RUN mkdir -p /backend/storage/logs \
    && chmod -R 777 /backend/storage

# Define o diretório de trabalho
WORKDIR /backend
