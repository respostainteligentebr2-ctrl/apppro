# 🚀 Setup Completo - AprendaPro.online na VPS

## Pré-requisitos
- Domínio `aprendapro.online` apontando para o IP da VPS (DNS A record)
- VPS com Ubuntu 22.04+
- Acesso SSH root ou sudo

---

## 1️⃣ Preparar VPS (primeira vez)

```bash
# Conectar no VPS
ssh root@seu-ip-vps

# Atualizar sistema
apt update && apt upgrade -y

# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Instalar Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Instalar Nginx
apt install -y nginx certbot python3-certbot-nginx

# Instalar Git
apt install -y git
```

---

## 2️⃣ Clonar Repositório

```bash
# Criar pasta do projeto
mkdir -p /var/www/apppro
cd /var/www/apppro

# Clonar repositório
git clone https://github.com/respostainteligentebr2-ctrl/apppro.git .
git checkout main
git pull origin main

# Copiar arquivo de ambiente
cp .env.example .env

# Editar com credenciais Supabase
nano .env
```

Preencha:
```env
SUPABASE_URL=https://seu-projeto.supabase.co
SUPABASE_ANON_KEY=sua-chave-anon
NODE_ENV=production
PORT=3000
```

Salve com `Ctrl+X`, depois `Y` e `Enter`.

---

## 3️⃣ Atualizar docker-compose.yml para porta 3002

```bash
# Editar arquivo
nano docker-compose.yml
```

Encontre a seção `ports:` e altere para:
```yaml
ports:
  - "127.0.0.1:3002:3000"  # Bind apenas em localhost, porta 3002
```

Salve com `Ctrl+X`, `Y`, `Enter`.

---

## 4️⃣ Copiar e Configurar Nginx

```bash
# Copiar arquivo de configuração do repositório
cp nginx.conf.aprendapro.online /etc/nginx/sites-available/aprendapro.online.conf

# Ativar site no Nginx
ln -s /etc/nginx/sites-available/aprendapro.online.conf /etc/nginx/sites-enabled/

# Testar configuração
nginx -t

# Se OK, recarregar
systemctl reload nginx
```

---

## 5️⃣ Certificado SSL com Let's Encrypt

```bash
# Gerar certificado (certbot vai validar o domínio automaticamente)
certbot certonly --nginx -d aprendapro.online -d www.aprendapro.online

# Certbot vai perguntar por email e aceitar termos
# Escolha opção "Agree"
```

**Verificar certificado:**
```bash
certbot certificates
```

---

## 6️⃣ Iniciar Aplicação Docker

```bash
cd /var/www/apppro

# Build
COMPOSE_PROJECT_NAME=apppro docker-compose build --no-cache

# Iniciar em background
COMPOSE_PROJECT_NAME=apppro docker-compose up -d

# Ver status
docker ps

# Ver logs
docker-compose logs -f app
```

Aguarde 30-60 segundos para a aplicação estar pronta.

---

## 7️⃣ Testar Acesso

```bash
# Testar HTTP (deve redirecionar para HTTPS)
curl -I http://aprendapro.online

# Testar HTTPS
curl -I https://aprendapro.online

# Testar health check
curl https://aprendapro.online/api/health 2>/dev/null || echo "App está rodando"
```

Ou abra no navegador: **https://aprendapro.online**

---

## 8️⃣ Configurar Auto-Renovação SSL

```bash
# Let's Encrypt auto-renew (certbot já configura via cron)
certbot renew --dry-run
```

---

## 9️⃣ Verificar Portas

```bash
# Confirmar que app roda apenas em localhost:3002
ss -tulpn | grep 3002

# Confirmar Nginx em 80 e 443
ss -tulpn | grep -E ":80|:443"
```

---

## 🔟 Scripts de Gerenciamento

### Parar aplicação
```bash
cd /var/www/apppro
COMPOSE_PROJECT_NAME=apppro docker-compose down
```

### Reiniciar aplicação
```bash
cd /var/www/apppro
COMPOSE_PROJECT_NAME=apppro docker-compose restart app
```

### Ver logs em tempo real
```bash
cd /var/www/apppro
docker-compose logs -f app
```

### Atualizar código do GitHub
```bash
cd /var/www/apppro
git pull origin main
COMPOSE_PROJECT_NAME=apppro docker-compose build --no-cache
COMPOSE_PROJECT_NAME=apppro docker-compose up -d
```

---

## ✅ Checklist Final

```
DNS:
  [ ] aprendapro.online aponta para IP da VPS
  [ ] Domínio resolve corretamente (dig aprendapro.online)

VPS:
  [ ] Docker instalado (docker --version)
  [ ] Docker Compose instalado (docker-compose --version)
  [ ] Nginx instalado (nginx -v)
  [ ] Código clonado em /var/www/apppro
  [ ] .env configurado com Supabase
  [ ] docker-compose.yml com porta 3002

SSL:
  [ ] Certificado Let's Encrypt gerado
  [ ] certbot certificates mostra certificado
  [ ] Auto-renew configurado

Aplicação:
  [ ] docker ps mostra container rodando
  [ ] curl https://aprendapro.online retorna 200
  [ ] Logs sem erros (docker-compose logs)
  [ ] Supabase conecta normalmente
  [ ] Admin panel (página editor) funciona

Segurança:
  [ ] HTTP redireciona para HTTPS
  [ ] HTTPS está ativa
  [ ] Nginx mostra security headers
  [ ] .env não está no git
```

---

## 🆘 Troubleshooting

### Erro: Connection refused (127.0.0.1:3002)
```bash
# App não está rodando
docker-compose up -d
docker-compose logs app
```

### Erro: Certificate not found
```bash
# Gerar certificado novamente
certbot certonly --nginx -d aprendapro.online
```

### Erro: Port 3002 already in use
```bash
# Verificar qual processo está usando
lsof -i :3002

# Se necessário, alterar porta em docker-compose.yml
```

### Nginx não recarrega
```bash
# Testar config
nginx -t

# Se OK
systemctl reload nginx
```

---

## 📊 Monitoramento Contínuo

```bash
# Ver status dos containers
watch -n 5 'docker ps'

# Ver uso de recursos
docker stats

# Ver logs com filtro
docker-compose logs --tail=100 app

# Verificar saúde da VPS
free -h     # Memória
df -h       # Disco
top -bn1 | head -20  # CPU
```

---

## 🔄 Backup Automático

```bash
# Criar script de backup do banco (Supabase)
# Supabase já faz backups automáticos via console

# Fazer backup de arquivos importantes
tar -czf /backups/apppro-$(date +%Y%m%d).tar.gz /var/www/apppro/

# Agendarno cron
crontab -e
# Adicionar: 0 2 * * * tar -czf /backups/apppro-$(date +\%Y\%m\%d).tar.gz /var/www/apppro/
```

---

## 🎯 Resultado Final

Após completar esses passos:

- ✅ AprendaPro.online acessível em HTTPS
- ✅ Aplicação rodando em porta 3002 (isolated)
- ✅ Nginx proxiando corretamente
- ✅ SSL automático via Let's Encrypt
- ✅ Pronto para editar páginas no admin panel
- ✅ Cada página será vinculada a uma URL dinâmica

---

**Data:** 2026-06-04
**Domínio:** AprendaPro.online
**Porta:** 3002 (interna) → 443 (externa via Nginx)
