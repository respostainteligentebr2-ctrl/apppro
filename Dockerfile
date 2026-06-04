# Estágio 1: Build
FROM node:20-alpine AS builder

WORKDIR /app

# Instalar pnpm (alternativa ao npm para melhor performance)
RUN npm install -g pnpm

# Copiar arquivos de dependências
COPY package.json package-lock.json* pnpm-lock.yaml* ./

# Instalar dependências
RUN npm install --legacy-peer-deps

# Copiar código-fonte
COPY . .

# Build da aplicação
RUN npm run build

# Estágio 2: Runtime
FROM node:20-alpine

WORKDIR /app

# Instalar pnpm
RUN npm install -g pnpm

# Definir variáveis de ambiente padrão
ENV NODE_ENV=production
ENV PORT=3000

# Copiar arquivos de dependências do builder
COPY package.json package-lock.json* pnpm-lock.yaml* ./

# Instalar apenas dependências de produção
RUN npm install --legacy-peer-deps --omit=dev

# Copiar build do estágio anterior
COPY --from=builder /app/dist ./dist

# Expor porta
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

# Comando para iniciar a aplicação
CMD ["node", "dist/server/index.mjs"]
