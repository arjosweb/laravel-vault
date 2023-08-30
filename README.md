# Iniciar projeto
````shell
docker-compose --env-file .env up -d
````
## Setup inicial

1. Após realizar o clone do projeto, instale as dependências do mesmo com:
```shell
docker run --rm -itv $(pwd):/backend -w /backend -u $(id -u):$(id -g) composer:2.5.8 install
```

2. Com as dependências instaladas, crie o arquivo de configuração `.env`:
```shell
cp .env.example .env
```

3. Inicie o ambiente _Docker_ executando:
```shell
docker compose up -d
```

4. Dê permissões ao usuário correto para escrever logs na aplicação
```shell
#docker compose exec backend chown -R www-data:www-data /app/storage
docker compose exec backend composer dump-autoload
```

5. Garanta que o contêiner de banco de dados está de pé. Os logs devem exibir a mensagem _ready for connections_ nas últimas linhas
```shell
docker compose logs database
``` 
Aguarde até que o comando acima tenha como uma das últimas linhas a mensagem _ready for connections_.

6. Para criar o banco de dados, execute:
```shell
docker compose exec backend php artisan migrate --seed
```

Muitos dados serão criados (1000 especialistas com 1000 avaliações cada), então essa última etapa será demorada. Enquanto ela executa, a API já estará acessível através do endereço http://localhost:8123/api. Além disso, o endereço http://localhost:8025 provê acesso ao serviço de e-mail _Mailpit_.

```shell
docker exec -it laravel-vault-docker-backend-1 sh
```
