# Desenvolvimento
### Inicializar localmente primeira vez
```shell
cd .. && bash <(curl -s "https://raw.githubusercontent.com/arjosweb/laravel-vault/master/deployment/Deploy.sh") && docker exec -it laravel-vault_backend_1 sh -c 'composer install && php artisan migrate'
```

### Iniciar projeto
````shell
docker-compose --env-file .env up -d
````

### Acessar bash do container do Laravel
```shell
docker exec -it laravel-vault-backend-1 sh
```
