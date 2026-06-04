# 🚀 AppPro - Plataforma de Aprendizado Profissional Inteligente

[![Build Status](https://github.com/seu-usuario/apppro/actions/workflows/ci-cd.yml/badge.svg)](https://github.com/seu-usuario/apppro/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

Uma plataforma moderna de e-learning construída com **TanStack React Start**, **Supabase** e **Tailwind CSS**. Totalmente versionada e pronta para deployment em VPS.

## ✨ Features

- 🎓 Plataforma de cursos moderna e responsiva
- 🔐 Autenticação segura com Supabase
- 🛡️ Sistema de autorização role-based
- 📱 Interface mobile-first
- 🎨 Design system com Shadcn/ui components
- ⚡ Server-side rendering (SSR) com TanStack Start
- 🔄 Real-time updates com Supabase
- 📊 Editor de páginas admin
- 🚀 Otimizado para performance

## 🛠️ Stack Tecnológico

- **Frontend**: React 19.2.0 + TypeScript
- **Routing**: TanStack Router 1.168.25
- **SSR Framework**: TanStack React Start 1.167.50
- **Backend**: TanStack Start + Nitro (Node.js)
- **Database**: Supabase (PostgreSQL)
- **UI Components**: Shadcn/ui + Radix UI
- **Styling**: Tailwind CSS 4.2.1
- **Build Tool**: Vite 7.3.1
- **Deployment**: Docker + Docker Compose

## 📋 Pré-requisitos

- Node.js 20+
- npm ou pnpm
- Supabase project
- Docker (opcional, para deployment)

## 🚀 Quick Start

### Desenvolvimento Local

```bash
# Instalar dependências
npm install --legacy-peer-deps

# Configurar variáveis de ambiente
cp .env.example .env
# Editar .env com suas credenciais Supabase

# Iniciar servidor de desenvolvimento
npm run dev

# Aplicação estará disponível em http://localhost:5173
```

### Build para Produção

```bash
# Build da aplicação
npm run build

# Testar build localmente
npm run preview

# A aplicação estará disponível em http://localhost:4173
```

## 📦 Deployment

### Opção 1: Docker (Recomendado)

```bash
# Build da imagem
docker-compose build

# Iniciar serviço
docker-compose up -d

# Verificar logs
docker-compose logs -f app
```

### Opção 2: VPS Direct

Veja [DEPLOYMENT.md](./DEPLOYMENT.md) para instruções detalhadas.

## 📁 Estrutura do Projeto

```
apppro/
├── src/
│   ├── components/        # Componentes React
│   │   ├── admin/        # Componentes de admin
│   │   ├── brand/        # Componentes de marca
│   │   ├── public/       # Componentes públicos
│   │   └── ui/           # Componentes UI (Shadcn)
│   ├── routes/           # Rotas TanStack Router
│   ├── lib/              # Utilidades e helpers
│   ├── integrations/     # Integrações (Supabase)
│   ├── hooks/            # React hooks customizados
│   ├── server.ts         # Configuração de servidor
│   ├── start.ts          # Arquivo de entrada
│   └── styles.css        # Estilos globais
├── public/               # Assets estáticos
├── supabase/             # Configuração Supabase
├── docker-compose.yml    # Docker Compose config
├── Dockerfile           # Docker build
├── vite.config.ts       # Configuração Vite
├── tsconfig.json        # TypeScript config
└── DEPLOYMENT.md        # Guia de deployment
```

## 🔧 Scripts Disponíveis

```bash
# Desenvolvimento
npm run dev           # Iniciar dev server
npm run build        # Build para produção
npm run preview      # Preview do build
npm run lint         # Lint com ESLint
npm run format       # Formatar com Prettier
```

## 🔐 Variáveis de Ambiente

```env
# Supabase
SUPABASE_URL=https://seu-projeto.supabase.co
SUPABASE_ANON_KEY=sua-chave-anon

# Application
NODE_ENV=production
PORT=3000
```

Copie `.env.example` para `.env` e preencha com suas credenciais.

## 🚀 Deployment

### Configuração Inicial

1. **VPS Setup**
   ```bash
   # SSH no servidor
   ssh root@seu-servidor-ip
   
   # Seguir instruções em DEPLOYMENT.md
   ```

2. **GitHub Actions CI/CD**
   - Configure os secrets do GitHub:
     - `VPS_HOST`: IP do seu VPS
     - `VPS_USER`: Usuário SSH
     - `VPS_SSH_KEY`: Chave privada SSH
     - `SUPABASE_URL`: URL do Supabase
     - `SUPABASE_ANON_KEY`: Chave anônima

3. **Configuração DNS**
   - Aponte seu domínio para o IP do VPS

### Monitoramento

```bash
# Com Docker Compose
docker-compose logs -f app

# Verificar saúde
curl https://seu-dominio.com/health
```

## 📚 Documentação

- [DEPLOYMENT.md](./DEPLOYMENT.md) - Guia completo de deployment
- [Supabase Docs](https://supabase.com/docs)
- [TanStack Router](https://tanstack.com/router)
- [Tailwind CSS](https://tailwindcss.com/docs)

## 🤝 Contribuindo

1. Fork o repositório
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📝 Checklist de Lançamento

- [ ] Todas as variáveis de ambiente configuradas
- [ ] Build compila sem erros
- [ ] Testes passam (se houver)
- [ ] Lint passa sem warnings
- [ ] Supabase migrations aplicadas
- [ ] SSL/HTTPS configurado
- [ ] Backup strategy em place
- [ ] Monitoring configurado
- [ ] Documentação atualizada

## 🐛 Troubleshooting

### Build falha
```bash
# Limpar node_modules e reinstalar
rm -rf node_modules package-lock.json
npm install --legacy-peer-deps
npm run build
```

### Erro de conexão Supabase
```bash
# Verificar .env
cat .env

# Testar conectividade
curl -I https://seu-projeto.supabase.co
```

### Docker container não inicia
```bash
# Verificar logs
docker-compose logs app

# Rebuild
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## 📄 Licença

Este projeto está sob a licença MIT. Veja arquivo [LICENSE](LICENSE) para detalhes.

## 👥 Autores

- **Seu Nome** - *Desenvolvimento Principal*

## 🙏 Agradecimentos

- TanStack por o excelente framework
- Supabase pela backend robusta
- Shadcn/ui pelos componentes UI
- A comunidade open source

## 📞 Suporte

Para suporte, abra uma [issue](https://github.com/seu-usuario/apppro/issues) ou [discussion](https://github.com/seu-usuario/apppro/discussions).

---

**Status**: ✅ Pronto para Produção
**Versão**: 1.0.0
**Última atualização**: 2026-06-04
