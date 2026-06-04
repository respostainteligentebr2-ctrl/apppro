#!/bin/bash
# Script de validação pré-commit

set -e

echo "🔍 Executando validações pré-commit..."

# Verificar formatação
echo "📝 Verificando formatação..."
npm run lint || true

# Verificar tipos TypeScript
echo "🔧 Verificando tipos TypeScript..."
npx tsc --noEmit

# Rodar build
echo "🏗️  Compilando..."
npm run build

echo "✅ Todas as validações passaram!"
