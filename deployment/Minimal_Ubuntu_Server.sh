#!/bin/bash
clear
echo "=================================================
        SCRIPT DE DEPLOY DE SERVIDORES
-------------------------------------------------
           OS: Linux (Ubuntu 20/22)
   Author: ARJOS - Desenvolvimento de Sistemas
================================================="
echo "🏗️  Iniciando deploy de Servidor..."

# Configura o local e o fuso horário
echo "🕙  Configurando o local e o fuso horário do Servidor..."
locale-gen pt_BR.UTF-8
export LANG=pt_BR.UTF-8
sudo timedatectl set-timezone "America/Sao_Paulo"
echo "✅  Etapa concluída!"

# Atualiza os pacotes do sistema
echo "📦  Atualizando os pacotes do sistema..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get upgrade -y
apt-get dist-upgrade -y
echo "✅  Etapa concluída!"

# Instala dependências gerais
echo "🔥  Instalando dependências gerais..."
apt-get install python3 python3-pip curl git nano unzip zip ffmpeg ufw -y
echo "✅  Etapa concluída!"

# Remove versões antigas do Docker
echo "🐳  Instalando e configurando o Docker..."
apt-get remove docker docker-engine docker.io containerd runc -y
# Instala o Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
# Adiciona o usuário atual ao grupo docker
usermod -aG docker $USER
# Instala o Docker Compose
DOCKER_COMPOSE_VERSION=$(curl --silent https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
curl -L "https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
echo "✅  Etapa concluída!"

# Instala e sobe container do Portainer (Gerenciador de Containers)
echo "🚢  Instalando e configurando o Portainer..."
read -p "⚠️  Deseja instalar o gerenciador de containers Portainer? [S/n] " resposta_p
resposta_lower_p=$(echo "$resposta_p" | tr '[:upper:]' '[:lower:]')
if [[ "$resposta_lower_p" == "sim" || "$resposta_lower_p" == "s" || "$resposta_lower_p" == "yes" || "$resposta_lower_p" == "y" ]]; then
    echo "Legal! Vamos configurar isso para você..."
    docker volume create portainer_data
    docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce
elif [[ "$resposta_lower_p" == "não" || "$resposta_lower_p" == "nao" || "$resposta_lower_p" == "n" || "$resposta_lower_p" == "no" ]]; then
    echo "Ok! O Portainer não foi instalado."
else
    echo "Resposta inválida. O Portainer não foi instalado."
fi
echo "✅  Etapa concluída!"

# Memória Swap
echo "🔋  Configurando Memória Swap..."
read -p "⚠️  Deseja criar uma memória SWAP? [S/n] " resposta
resposta_lower=$(echo "$resposta" | tr '[:upper:]' '[:lower:]')
# Verifica a resposta e imprime o resultado correspondente
if [[ "$resposta_lower" == "sim" || "$resposta_lower" == "s" || "$resposta_lower" == "yes" || "$resposta_lower" == "y" ]]; then
    echo "Legal! Vamos configurar isso para você..."
    read -p "⚠️  Qual o tamanho da memória em Gigabytes (ex: 4G)? " swap_size
    if [[ "$swap_size" ]]; then
        swap_size_upper=$(echo "$swap_size" | tr '[:lower:]' '[:upper:]')
        # Cria e configura Memória Swap (4G)
        sudo fallocate -l "$swap_size_upper" /swapfile \
            && sudo chmod 600 /swapfile \
            && sudo mkswap /swapfile \
            && sudo swapon /swapfile \
            && sudo swapon --show \
            && free -h
        echo "/swapfile swap swap defaults 0 0" >> /etc/fstab
        echo "A memória Swap de $swap_size_upper foi configurada!"
    else
        echo "Você não digitou nada..."
    fi
elif [[ "$resposta_lower" == "não" || "$resposta_lower" == "nao" || "$resposta_lower" == "n" || "$resposta_lower" == "no" ]]; then
    echo "Ok! A memória Swap não será configurada..."
else
    echo "Resposta inválida"
fi
echo "✅  Etapa concluída!"

# Limpa arquivos temporários
echo "🧹  Limpando arquivos temporários..."
sudo apt autoremove -y \
    && apt autoclean -y

sudo apt-get clean -y
sudo rm -rf /var/lib/apt/lists/*
sudo apt-get update -y
sudo apt-get install -y
echo "✅  Etapa concluída!"

# Aumenta limites do servidor: Conexões
echo "🛠  Aumentando limites de Conexões do servidor..."
rm /etc/sysctl.conf
echo "fs.file-max = 1500000
net.core.somaxconn = 1500000
net.ipv4.tcp_max_syn_backlog = 1500000
" >> /etc/sysctl.conf
echo "✅  Etapa concluída!"

# Aumenta limites do servidor: Processos
echo "🚚  Aumentando limites de Processos do servidor..."
rm /etc/security/limits.conf
echo "www-data soft nofile 1500000
www-data hard nofile 1500000
root soft nofile 1500000
root hard nofile 1500000
* soft nofile 1500000
* hard nofile 1500000
* soft nproc 1500000
* hard nproc 1500000
mysql soft nofile 1500000
mysql hard nofile 1500000
* soft nproc unlimited
* hard nproc unlimited" >> /etc/security/limits.conf
echo "✅  Etapa concluída!"

# Recarrega configurações das tarefas Cron do sistema
echo "🎯  Recarregando configurações das tarefas Cron do sistema..."
sudo systemctl daemon-reload
sysctl -p
systemctl enable cron.service \
    && service cron restart
echo "✅  Etapa concluída!"

# Removendo arquivos temporários
echo "🧹  Limpando arquivos temporários..."
sudo apt-get update -y \
    && apt list --upgradable \
    && apt upgrade -y \
    && apt dist-upgrade -y \
    && apt autoremove -y \
    && apt autoclean -y \
    && apt clean -y
echo "✅  Etapa concluída!"

# Finaliza Deploy com Reboot do Servidor
echo "🚀  DEPLOY CONCLUÍDO! Você deve reiniciar o servidor..."
read -p "⚠️  Deseja reiniciar agora? [S/n] " resposta_p
resposta_lower_p=$(echo "$resposta_p" | tr '[:upper:]' '[:lower:]')
if [[ "$resposta_lower_p" == "sim" || "$resposta_lower_p" == "s" || "$resposta_lower_p" == "yes" || "$resposta_lower_p" == "y" ]]; then
    echo "Até a próxima! ;)"
    reboot
elif [[ "$resposta_lower_p" == "não" || "$resposta_lower_p" == "nao" || "$resposta_lower_p" == "n" || "$resposta_lower_p" == "no" ]]; then
    echo "Ok! O servidor não será reiniciado... Reinicie quando puder."
else
    echo "Resposta inválida. O servidor não será reiniciado."
fi
echo "✅  Etapa concluída!"

# Steps:
# 1) nano Minimal_Ubuntu_Server.sh
# 2) chmod +x Minimal_Ubuntu_Server.sh
# 3) sudo bash ./Minimal_Ubuntu_Server.sh
