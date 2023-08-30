#!/bin/bash
clear
echo "=================================================
            LARAVEL VAULT PROJECT
-------------------------------------------------
          Open Source Password Manager
        Author: ARJOS (https://arjos.eu)
================================================="
echo "🏗️ Iniciando a instalação do seu Gerenciador de Senhas..."

docker info > /dev/null 2>&1

# Ensure that Docker is running...
if [ $? -ne 0 ]; then
    echo "O Docker não está rodando no seu servidor... Instalação não realizada!"
    exit 1
fi

# DEFAULT
IP=''
APP_PORT=9001
PMA_HOST=database
PMA_PORT=9999
DB_PORT=3306
DB_HOST=database
DB_DATABASE=laravel_vault
DB_USERNAME=laravel_vault
DB_PASSWORD=laravel_vault_pwd
CACHE_DRIVER=redis

echo "⚙️  Configurando opções da aplicação..."
# IP
read -p "⚠️  Qual o endereço de IP do seu servodor? (Ex: 192.168.15.0) " resposta_ip
resposta_lower_ip=$(echo "$resposta_ip" | tr '[:upper:]' '[:lower:]')
if [[ $resposta_lower_ip ]]; then
    IP="$resposta_lower_ip"
else
    echo "$IP"
fi

# APP_PORT
read -p "⚠️  Qual a porta que deseja rodar o seu Gerenciador de senhas? (Ex: 9001) " resposta_port
resposta_lower_port=$(echo "$resposta_port" | tr '[:upper:]' '[:lower:]')
if [[ $resposta_lower_port ]]; then
    APP_PORT="$resposta_lower_port"
else
    echo "$APP_PORT"
fi

# PMA_HOST
read -p "⚠️  Qual a porta que deseja rodar o PHPMyAdmin? (Ex: 9999) " resposta_port_pma
resposta_lower_port_pma=$(echo "$resposta_port_pma" | tr '[:upper:]' '[:lower:]')
if [[ $resposta_lower_port_pma ]]; then
    PMA_PORT="$resposta_lower_port_pma"
else
    echo "$PMA_PORT"
fi

# DB_PORT
read -p "⚠️  Qual a porta que deseja rodar o seu Banco de Dados MySQL? (Ex: 3306) " resposta_port_db
resposta_lower_port_db=$(echo "$resposta_port_db" | tr '[:upper:]' '[:lower:]')
if [[ $resposta_lower_port_db ]]; then
    DB_PORT="$resposta_lower_port_db"
else
    echo "$DB_PORT"
fi

# DB_DATABASE
read -p "⚠️  Qual ao nome do seu banco de dados? (Ex: laravel_vault) " resposta_db
resposta_lower_db=$(echo "$resposta_db" | tr '[:upper:]' '[:lower:]')
if [[ $resposta_lower_db ]]; then
    DB_DATABASE="$resposta_lower_db"
else
    echo "$DB_DATABASE"
fi

# DB_USERNAME
read -p "⚠️  Qual o nome de usuário do seu banco de dados? (Ex: laravel_vault) " resposta_db_user
resposta_lower_db_user=$(echo "$resposta_db_user" | tr '[:upper:]' '[:lower:]')
if [[ $resposta_lower_db_user ]]; then
    DB_USERNAME="$resposta_lower_db_user"
else
    echo "$DB_USERNAME"
fi

# DB_PASSWORD
read -p "⚠️  Qual a senha do seu banco de dados? (Ex: laravel_vault_pwd) " resposta_db_pwd
resposta_lower_db_pwd=$(echo "$resposta_db_pwd" | tr '[:upper:]' '[:lower:]')
if [[ $resposta_lower_db_pwd ]]; then
    DB_PASSWORD="$resposta_lower_db_pwd"
else
    echo "$DB_PASSWORD"
fi

# Baixa Repo
echo "📦  Baixando repositório..."
git clone https://github.com/arjosweb/laravel-vault.git
echo "✅  Etapa concluída!"

## Permissão na pasta
echo "🔒 Concedendo permissões..."
chmod +x laravel-vault
sudo chmod 777 -R laravel-vault/backend/
echo "✅  Etapa concluída!"

# Cria o .env do projeto Laravel
echo "🔥  Configurando projeto..."

# Remove .env existentes
if [ -f "laravel-vault/docker/.env.example" ]; then
    rm -R laravel-vault/docker/.env.example
fi

if [ -f "laravel-vault/docker/laravel/.env" ]; then
    rm -R laravel-vault/docker/laravel/.env
fi

if [ -f "laravel-vault/.env" ]; then
    rm -R laravel-vault/.env
fi

# Copia a base padrão do .env do Laravel
cp laravel-vault/docker/laravel/.env.example laravel-vault/docker/.env.example

# Adiciona variáveis no novo arquivo .env.example
echo "
APP_PORT=${APP_PORT}
PMA_HOST=${PMA_HOST}
PMA_PORT=${PMA_PORT}
DB_PORT=${DB_PORT}
DB_HOST=${DB_HOST}
DB_DATABASE=${DB_DATABASE}
DB_USERNAME=${DB_USERNAME}
DB_PASSWORD=${DB_PASSWORD}
#CACHE_DRIVER=${CACHE_DRIVER}
" >> laravel-vault/docker/.env.example

# Cria o .env do Docker e do Laravel
cp laravel-vault/docker/.env.example laravel-vault/.env
cp laravel-vault/docker/.env.example laravel-vault/docker/laravel/.env
cp laravel-vault/.env laravel-vault/backend/.env

# Cria Docker Compose Padrão
if [ -f "laravel-vault/docker-compose.yaml" ]; then
    rm -R laravel-vault/docker-compose.yaml
fi

echo "# docker-compose.yaml
version: '3.8'

# Cria a rede
networks:
  vault_network:
    driver: bridge

# Inicializa os Containers
services:
  # Laravel APP
  backend:
    build:
      context: .
      dockerfile: docker/Dockerfile
    volumes:
      - ./backend:/backend
      - ./docker/laravel/.env:/backend/.env
    #command: sh -c 'composer install && php artisan migrate'
    working_dir: /backend
    depends_on:
      - database
    networks:
      - vault_network

  # Nginx
  proxy:
    image: nginx:1.25
    ports:
      - "${APP_PORT-9000}:80"
    volumes:
      - ./docker/nginx.conf:/etc/nginx/conf.d/default.conf
    depends_on:
      - backend
    networks:
      - vault_network

  # DB MySQL
  database:
    image: mariadb
    restart: unless-stopped
    environment:
      MYSQL_USER: ${DB_USERNAME-laravel_vault}
      MYSQL_PASSWORD: ${DB_PASSWORD-laravel_vault_pwd}
      MYSQL_DATABASE: ${DB_DATABASE-laravel_vault}
      MYSQL_ROOT_PASSWORD: ${DB_PASSWORD-laravel_vault_pwd}
    volumes:
      - ./database/mysql:/var/lib/mysql
    networks:
      - vault_network

  # PHPMyAdmin
  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    restart: always
    depends_on:
      - database
    environment:
      PMA_HOST: database
      PMA_PORT: ${DB_PORT-3306}
      PMA_ARBITRARY: 1
      PMA_CONTROLHOST: database
      PMA_CONTROLPORT: ${DB_PORT-3306}
    volumes:
      - ./docker/php/custom.ini:/usr/local/etc/php/conf.d/uploads.ini
    ports:
      - ${PMA_PORT-8888}:80
    networks:
      - vault_network

  # Optional Installations
  # Redis (OPTIONAL)
  cache:
    image: redis:7
    networks:
      - vault_network
" > laravel-vault/docker-compose.yaml
echo "✅  Etapa concluída!"

# Colocar de forma mais permanente
echo "🚀  Inicializando aplicações..."
cd laravel-vault/ && docker-compose --env-file .env up -d
docker exec laravel-vault-backend-1 sh -c "composer install && php artisan key:generate --force && php artisan migrate --seed --force && php artisan storage:link"
echo "✅  Etapa concluída!"

echo "
=======================================================
  ACESSE SUA APLICAÇÃO!
-------------------------------------------------------
  Gerenciador de Senhas: http://${IP}:${APP_PORT}
  PHPMyAdmin: http://${IP}:${PMA_PORT}
=======================================================
"

# Steps:
# 1) nano Deploy.sh
# 2) chmod +x Deploy.sh
# 3) bash ./Deploy.sh

# curl -s "https://raw.githubusercontent.com/arjosweb/laravel-vault/master/deployment/Deploy.sh" | bash
# curl "https://raw.githubusercontent.com/arjosweb/laravel-vault/master/deployment/Deploy.sh" | bash
# bash <(curl -s "https://raw.githubusercontent.com/arjosweb/laravel-vault/master/deployment/Deploy.sh")
