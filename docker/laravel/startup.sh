#!/bin/bash
# Instalar dependências com o Composer
composer install

# Rodar as migrations
php artisan migrate --seed --force

# Gerar a chave do Laravel
php artisan key:generate

