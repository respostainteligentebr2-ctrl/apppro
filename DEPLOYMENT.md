# 📚 Guia de Deployment - AppPro

## Visão Geral

Este documento descreve como fazer deploy da aplicação AppPro em um VPS (Ubuntu 22.04+). A aplicação é um projeto TanStack React Start com Supabase como backend.

## Pré-requisitos

- Ubuntu 22.04 LTS ou superior
- Node.js 20+ instalado
- npm ou pnpm instalado
- Docker (recomendado) ou acesso direto ao servidor
- Supabase project configurado
- Domínio DNS configurado (opcional, mas recomendado)

## Opção 1: Deployment com Docker (Recomendado)

### 1. Preparar o Servidor

```bash
# Conectar ao servidor
ssh root@seu-servidor-ip

# Atualizar sistema
apt update && apt upgrade -y

# Instalar Docker e Docker Compose
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Instalar Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verificar instalação
docker --version
docker-compose --version
```

### 2. Clonar Repositório

```bash
# Navegar até diretório de aplicações
cd /var/www

# Clonar repositório
git clone https://github.com/seu-usuario/apppro.git
cd apppro

# Checkout para a branch principal
git checkout main
```

### 3. Configurar Variáveis de Ambiente

```bash
# Copiar arquivo de exemplo
cp .env.example .env

# Editar com suas credenciais Supabase
nano .env
```

Preencher:
```
SUPABASE_URL=https://seu-projeto.supabase.co
SUPABASE_ANON_KEY=sua-chave-anon
```

### 4. Build e Deploy com Docker

```bash
# Build da imagem Docker
docker-compose build

# Iniciar serviço
docker-compose up -d

# Verificar logs
docker-compose logs -f app

# Parar serviço (se necessário)
docker-compose down
```

### 5. Configurar Reverse Proxy com Nginx

```bash
# Instalar Nginx
apt install -y nginx

# Criar arquivo de configuração
sudo tee /etc/nginx/sites-available/apppro > /dev/null <<EOF
server {
    listen 80;
    server_name seu-dominio.com;

    # Redirecionar HTTP para HTTPS
    return 301 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    server_name seu-dominio.com;

    # Certificados SSL (ver seção abaixo)
    ssl_certificate /etc/letsencrypt/live/seu-dominio.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/seu-dominio.com/privkey.pem;

    # Configurações de segurança SSL
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # Proxy para a aplicação
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_cache_bypass \$http_upgrade;
        
        # Timeouts para uploads/downloads maiores
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # Compressão
    gzip on;
    gzip_vary on;
    gzip_min_length 1000;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/json;
}
EOF

# Ativar configuração
sudo ln -s /etc/nginx/sites-available/apppro /etc/nginx/sites-enabled/
sudo nginx -t  # Testar configuração
sudo systemctl restart nginx
```

### 6. Configurar SSL com Let's Encrypt

```bash
# Instalar Certbot
apt install -y certbot python3-certbot-nginx

# Gerar certificado
certbot certonly --nginx -d seu-dominio.com

# Renovação automática (certbot já configura via cron)
certbot renew --dry-run
```

### 7. Configurar Auto-update e Monitoramento

```bash
# Criar script de atualização
sudo tee /opt/apppro-deploy.sh > /dev/null <<'EOF'
#!/bin/bash
set -e

cd /var/www/apppro

# Pull latest code
git pull origin main

# Build e restart
docker-compose build
docker-compose up -d

# Log
echo "Deploy completo em $(date)" >> /var/log/apppro-deploy.log
EOF

# Tornar executável
chmod +x /opt/apppro-deploy.sh

# Adicionar ao crontab para atualizar diariamente
(crontab -l 2>/dev/null; echo "0 2 * * * /opt/apppro-deploy.sh") | crontab -
```

## Opção 2: Deployment Direto no VPS (Sem Docker)

### 1. Instalar Dependências

```bash
# Instalar Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
apt install -y nodejs

# Instalar PM2 (gerenciador de processos)
npm install -g pm2
```

### 2. Clonar e Preparar

```bash
cd /var/www
git clone https://github.com/seu-usuario/apppro.git
cd apppro
cp .env.example .env
nano .env  # Configurar Supabase
```

### 3. Build

```bash
npm install --legacy-peer-deps
npm run build
```

### 4. Iniciar com PM2

```bash
# Criar arquivo de configuração PM2
cat > ecosystem.config.js <<EOF
module.exports = {
  apps: [{
    name: "apppro",
    script: "./dist/server/index.mjs",
    env: {
      NODE_ENV: "production",
      PORT: 3000
    },
    error_file: "/var/log/apppro-error.log",
    out_file: "/var/log/apppro-out.log",
    log_date_format: "YYYY-MM-DD HH:mm:ss Z",
    watch: false,
    max_memory_restart: "1G",
    instances: 2,
    exec_mode: "cluster"
  }]
};
EOF

# Iniciar aplicação
pm2 start ecosystem.config.js

# Configurar para iniciar automaticamente
pm2 startup
pm2 save

# Verificar status
pm2 status
pm2 logs apppro
```

## Monitoramento e Manutenção

### Verificar Saúde da Aplicação

```bash
# Com Docker
docker ps -a
docker-compose logs -f app

# Com PM2
pm2 status
pm2 logs
pm2 monit

# Testar endpoint
curl -I https://seu-dominio.com/
```

### Backups de Dados

```bash
# Backup de banco de dados Supabase (via console web ou CLI)
# Recomendação: usar snapshots automáticos do Supabase

# Backup de configurações locais
tar -czf /backups/apppro-config-$(date +%Y%m%d).tar.gz .env
```

### Atualizar Aplicação

```bash
# Com Docker
cd /var/www/apppro
git pull origin main
docker-compose build
docker-compose up -d

# Com PM2
git pull origin main
npm install --legacy-peer-deps
npm run build
pm2 restart apppro
```

## Troubleshooting

### Problema: Aplicação não inicia

```bash
# Verificar logs
docker-compose logs app      # Docker
pm2 logs apppro             # PM2

# Verificar porta está disponível
lsof -i :3000

# Verificar variáveis de ambiente
cat .env
```

### Problema: Erro de conexão Supabase

```bash
# Verificar credenciais em .env
# Verificar conectividade
curl -I https://seu-projeto.supabase.co

# Testar no código
curl https://seu-dominio.com/api/test
```

### Problema: Falta memória

```bash
# Aumentar limite de memória em docker-compose.yml ou PM2
# Com PM2: alterar max_memory_restart

# Verificar uso
free -h
docker stats  # Docker
pm2 monit    # PM2
```

## Checklist de Deployment

- [ ] Repository clonado do GitHub
- [ ] Node.js 20+ instalado
- [ ] Arquivo `.env` configurado com credenciais Supabase
- [ ] `npm install --legacy-peer-deps` executado
- [ ] `npm run build` executado com sucesso
- [ ] Docker e Docker Compose instalados (se usando Docker)
- [ ] Nginx instalado e configurado
- [ ] Certificado SSL instalado (Let's Encrypt)
- [ ] Domínio DNS apontando para IP do servidor
- [ ] Aplicação iniciada (Docker ou PM2)
- [ ] Nginx está roteando para a aplicação
- [ ] HTTPS funciona corretamente
- [ ] Health check retorna 200 OK
- [ ] Supabase connections testadas
- [ ] Logs sendo registrados corretamente
- [ ] Backup strategy em lugar
- [ ] Auto-update configurado

## Variáveis de Ambiente Necessárias

| Variável | Descrição | Exemplo |
|----------|-----------|---------|
| `SUPABASE_URL` | URL do projeto Supabase | `https://abc123.supabase.co` |
| `SUPABASE_ANON_KEY` | Chave anônima do Supabase | `eyJhbG...` |
| `NODE_ENV` | Ambiente | `production` |
| `PORT` | Porta da aplicação | `3000` |

## Segurança

- ✅ Use HTTPS sempre
- ✅ Mantenha `.env` fora do repositório (use `.env.example`)
- ✅ Use secrets do GitHub Actions para CI/CD
- ✅ Revise logs regularmente
- ✅ Faça backups automáticos
- ✅ Mantenha dependencies atualizadas
- ✅ Use firewalls (iptables ou ufw)
- ✅ Configure rate limiting no Nginx

## Suporte

Para mais informações sobre componentes utilizados:

- [TanStack React Start](https://tanstack.com/start)
- [Supabase Documentation](https://supabase.com/docs)
- [Docker Documentation](https://docs.docker.com)
- [Nginx Documentation](https://nginx.org/en/docs/)

---

**Última atualização:** 2026-06-04
**Versão:** 1.0
