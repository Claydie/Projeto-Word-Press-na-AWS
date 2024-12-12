#!/bin/bash

# Subir o contêiner do WordPress
# Atualiza os pacotes disponíveis
apt-get update -y

# Instala os pacotes necessários
apt-get install -y ca-certificates curl gnupg

# Configuração do Docker
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Inicia o Docker e adiciona permissões ao usuário
systemctl start Docker
usermod -aG docker ubuntu
systemctl enable docker


# Instalação do EFS dentro da EC2
sudo apt install nfs-common -y

# Criar ponto de montagem do EFS
mkdir -p /efs
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-xxxxxxxxxxxxxxx.efs.us-east-1.amazonaws.com:/ /efs
sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

#cria o docker compose.yaml
cat << EOF > docker-compose.yaml
services:

  wordpress:
    image: wordpress
    restart: always
    ports:
     - 8080:80
    environment:
      WORDPRESS_DB_HOST: endpoint do RDS                       
      WORDPRESS_DB_USER: usuario da sua preferencia
      WORDPRESS_DB_PASSWORD: senha da sua preferencia
      WORDPRESS_DB_NAME: wordpressdb
    volumes:
     - /efs/site:/var/www/html
EOF

cd /
docker-compose -p wp up -d
