# PROJETO COMPASS UOL (DOCKER COM WORDPRESS NA AWS)


**Descrição do Projeto**

Projeto com o intuito de demonstrar como funciona a  implementação e uma aplicação WordPress em uma instância EC2 privada na AWS, usando Docker e Docker Compose, conectando-se a um banco de dados RDS, e tornando o site acessível através de um Classic Load Balancer. A infraestrutura inicial do projeto inclui VPC, subnets públicas e privadas, NAT Gateway, Security Groups e outras configurações essenciais para um contexto geral do projeto.

[Estrutura do Projeto](#Estrutura-do-projeto)
- [Requisitos necessários](#requisitos-necessários)
- [Passo a Passo](#passo-a-passo)
  - [1. Configuração da VPC](#1-configuração-da-vpc)
  - [2. Configuração das Subnets](#2-configuração-das-subnets)
  - [3. Configuração do Internet Gateway](#3-configuração-do-internet-gateway)
  - [4. Configuração do Gateway NAT](#4-configuração-do-gateway-NAT)
  - [5. Configuração das Tabelas de Roteamento](#5-configuração-das-tabelas-de-roteamento)
  - [6. Configuração dos Security Groups](#6-configuração-dos-security-groups)
  - [7. Lançamento da Instância EC2 Privada](#7-lançamento-da-instância-ec2-privada)
  - [8. Configuração de EFS- Amazon Elastic File system](#8-configuração-de-EFS-Amazon-Elastic-File-system)
  - [9. Montagem do pacote EFS no terminal](#9-montagemdo-do-pacote-EFS-no-terminal)
  - [10. Configuração do RDS MySQL](#10-configuração-do-rds-mysql)
  - [11. Configuração do Load Balancer Clássico](#11-configuração-do-load-balancer-clássico)
  - [12. Implantação do WordPress com Docker](#12-implantação-do-wordpress-com-docker)
  - [13. Testes e Validação](#13-testes-e-validação)
  - [14. Auto Scaling](#14-Auto-Scaling)
- [Referências](#referências) 


 **Requisitos necessários**

- Conta na AWS com permissões adequadas.
- Chave SSH para acesso às instâncias EC2.
- Conhecimento básico em AWS, Docker e WordPress.
---
- Acessar o Console da AWS
- Acesse o AWS Management Console.
- Faça login com suas credenciais (usuário e senha, ou MFA, se configurado). 
---
1. **Configuração da VPC**

- Criar uma VPC 

- Nome: projetocompass-vpc (nome da sua preferência)

- Bloco CIDR IPv4: 10.0.0.0/16

 - No Console da AWS:

- Acesse o serviço VPC.

- Selecione Your VPCs e clique em Create VPC.

- Insira os detalhes acima e crie a VPC.
---
2. **Configuração das Subnets**

- Subnet Pública:

- Nome: nova(nome da sua preferência)-subnet-public1-us-east-1a
  
- Bloco CIDR: 10.0.1.0/24

- Zona de Disponibilidade: us-east-1a

- Subnet Privada:

- Nome: privadanv(nome da sua preferência)-subnet-private1-us-east-1a

- Bloco CIDR: 10.0.2.0/24

- Zona de Disponibilidade: us-east-1a
  
- No Console da AWS:

- Acesse Subnets dentro do serviço VPC.

- Crie as subnets com os detalhes acima.
---
3. **Configuração do Internet Gateway**

- Nome: mynatt

- Associar à VPC: projetocompass-vpc

- No Console da AWS:

- Acesse Internet Gateways no serviço VPC.

- Crie o IGW e associe-o à VPC.
---
4. **Configuração do NAT Gateway**

- Subnet: Subnet-Publica

- Elastic IP: Alocar um novo Elastic IP

- No Console da AWS:

- Acesse NAT Gateways dentro do serviço VPC.

- Crie o NAT Gateway e configure o Elastic IP.
---
5. **Configuração das Tabelas de Roteamento**

- Tabela de Roteamento da Subnet Pública:

- Rota: 0.0.0.0/0 via Internet Gateway (mynatt)

- Tabela de Roteamento da Subnet Privada:

- Rota: 0.0.0.0/0 via NAT Gateway (mynatt)

- No Console da AWS:

- Acesse Route Tables(tabela de rotas) no serviço VPC.

- Atualize as tabelas de roteamento conforme necessário.
---
6. **Configuração dos Security Groups**

- Security Groups-Privado:
 
- Nome: privadaec2(nome da sua preferência)

*Regras de Entrada:*

- HTTP: Porta 80, origem : loadbalancer2

- SSH: Porta 22, origem : BHost
---
**Security Groups-Load Balancer:**
- Nome:loadbalance2 (nome da sua preferência)

 *Regras de Entrada:*

- HTTP: Porta 80, origem: 0.0.0.0/0
---
**Security Groups-RDS:**
- Nome: meurds (nome da sua preferência)

 *Regras de Entrada:*

- MySQL/Aurora: Porta 3306, origem : SG-Privado

- No Console da AWS: 
---
**Security Groups-EFS**

- Nome: meuefs (nome da sua preferência)
  
- Regras de Entrada:
  
- NFS: Porta 2049 Origem: 10.0.0/16
 
- Acesse Security Groups no serviço EC2.
  
- Crie os grupos com as regras de entrada e saída descritas.
---
7. **Lançamento da Instância EC2 Privada**

- AMI: Ubuntu 24.04
  
- Tipo de Instância: t2.micro
  
- Subnet: Subnet-Privada

- Security Group: SG-Privado
  
- No Console da AWS:

- Acesse o serviço EC2.

- Execute uma instância com as configurações acima.
---
8. **configuração de EFS- Amazon Elastic File system** 
- Criar file system
  
- customize
   
- Nome: novoefs (nome da sua preferência)
  
- VPC: projetocompass-vpc (montar na sua VPC)
  
- VPC: Privada zonas 1a e 1b
  
- Security Group: meuefs (nome da sua preferência)
---
9. **Montagem do pacote no terminal**
 
 `` sudo apt install nfs-common -y``

**Criar ponto de montagem do EFS**

 ``mkdir -p /efs``
 ``sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-(copiar o efs do console).efs.us-east-1.amazonaws.com:/ /efs``
  
`` sudo curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose``
  
`` sudo chmod +x /usr/local/bin/docker-compose``
 
10. **Configuração do RDS MySQL**
- Engine: MySQL
  
- Versão: Compatível com o WordPress
  
- Instância: db.t3.micro
  
- Credenciais: Username e password
   
- Subnet Group: Subnets privadas
  
- Security Group: SG-RDS
  
- No Console da AWS:

- Acesse o serviço RDS.
  
- Crie o banco com os detalhes acima.

11. **Configuração do Load Balancer**

- Nome:meulb (nome da sua preferência)
  
- VPC: projetocompass-vpc
  
- Subnets: Subnet-Publica
  
- Security Group: wordwpress-LoadBalancer
  
- No Console da AWS:

- Acesse o serviço EC2, em Load Balancers.

- Configure o Health Check:

-Ping Protocol: HTTP

-Ping Port: 8080

-Ping Path: /wp-admin/install.php

-Adicione a instância de destino da EC2 privada.

12. **Implantação do WordPress com Docker**

- Instalar Docker e Docker Compose:
  
`` sudo amazon-linux-extras install docker -y``
``sudo service docker start``
`` sudo usermod -a -G docker ec2-user``
`` sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose``
`` sudo chmod +x /usr/local/bin/docker-compose``

`` Criar o arquivo docker-compose.yml:
services:
  wordpress:
    image: wordpress:latest
    ports:
      - "8080:80"
    environment:
      WORDPRESS_DB_HOST: <seu endpoint rds>
      WORDPRESS_DB_USER: <seu usuário>
      WORDPRESS_DB_PASSWORD: <sua senha>
      WORDPRESS_DB_NAME: <nome da database>
    volumes:
      - /efs/site:/var/www/html``

**Implementar WordPress:**
``mkdir ~/wp && cd ~/wp``
``sudo vim docker-compose.yml  # Cole o conteúdo acima``
``docker-compose up -d``

**Verificar logs e status:**
``docker ps``
``docker logs`` <id-do-conteiner>

---
13. **Testes e Validação**

- Verificar o Status do Load Balancer:
  
- Certifique-se de que a instância está InService (em serviço)

- Acessar o WordPress via Navegador:

- Acesse: http://<DNS-do-Load-Balancer>.
---
**Concluir a Instalação do WordPress:**

-Siga as instruções na tela para configurar o WordPress.

- Resumo da Instalação do WordPress com Docker e Docker Compose
  
- Após rodar o comando docker compose up -d, o WordPress estará em funcionamento.
- Para concluir instalação, siga os passos abaixo:

- Acessar o WordPress no Navegador:
  
- Acesse o endereço http://<DNS-do-Load-Balancer+/wp-admin> no navegador.

**Configuração Inicial do Word Press no navegador:**
Escolha o idioma (ex: "Português do Brasil").
O WordPress buscará automaticamente as configurações do banco de dados a partir das variáveis no docker-compose.yaml.

- Caso necessário, insira manualmente as informações:
  
- Nome do Banco de Dados
○Usuário
○Senha
○Host

**Configuração do Site:**
- Preencha as informações do site:
  
- Título do site
  
- Nome de usuário e senha do administrador
  
- E-mail do administrador
  
- Visibilidade do site (geralmente, público)

**Finalizar a Instalação:**
- Clique em Instalar WordPress.
  
- Após a instalação, você verá a mensagem de sucesso.
  
- Login no WordPress:
  
- Acesse o painel de administração em http://<seu_ip>/wp-admin.
  
- Use as credenciais do administrador para configurar seu site.
  
- Nota: O processo de instalação do WordPress é basicamente a configuração do idioma, banco de dados,  
  título do site e credenciais de administrador.

  ---
  14. **Auto Scaling**

  - Configuração.
  - 
  - Criar o grupo de auto scaling.

  - **Etapa 1 (inicial**)
  - Nome
  - Modelo de execução (colocar modelo salvo)
  - Versão (sempre a ultima)(latest)

  - **Etapa 2 (VPC e Subnet)**
  - Rede (colocar a VPC salva: projetocompass-vpc)
  - Subredes (colocar as privada1 e privada2)

  - **Etapa 3 (load balance)**
  - 1. Balanceamento de carga
  - Anexar a um load balance existente (adicionar o load balance que vc criou)
  - 2. Opções de integração do VPC Lattice
  - Serviço VPC Lattice não disponível
 
  - **Etapa 4 (configuração do Cluster)**
  - Tamanho do grupo
  - Capacidade desejada (2)
  - Escalabilidade
  - Capacidade mínima desejada (2)
  - Capacidade maxima desejada (4)
  - Ajuste de escala automática - opcional - Nenhuma olitica de escalabilidade
  - Política de manutenção de instâncias - Nenhuma politica

    - As demais opções, não marcar nada, e ir clicando em proximo até chegar na parte de criar auto scaling.

**Referências**

- [Documentação AWS VPC](https://aws.amazon.com/vpc/)
- [Documentação AWS EC2](https://aws.amazon.com/ec2/)
- [Documentação AWS RDS](https://aws.amazon.com/rds/)
- [Documentação Docker](https://docs.docker.com/)
- [Documentação WordPress](https://wordpress.org/support/)
---
**Repositório**

- `README.md`: Documentação detalhada do projeto (este arquivo).
- `docker-compose.yml`: Arquivo de configuração do Docker Compose.
- `scripts/`: (Opcional) Scripts auxiliares.
  


 
