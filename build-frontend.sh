#!/bin/bash

set -e

echo "=============================================="
echo "  📦 Compilando Frontend (fora do Docker)"
echo "=============================================="

cd /Volumes/ExternalMACOS/Diego/programacao/appsmith-inforcfc/app/client

echo ""
echo "⏳ Instalando dependências..."
yarn install

echo ""
echo "🔨 Compilando aplicação..."
echo "   (Isso pode levar 5-10 minutos)"
yarn build

echo ""
echo "✅ Build concluído!"
echo "   📁 Arquivos em: app/client/build/"
echo ""
echo "Agora execute: ./docker-dev-start.sh"
echo "O Nginx vai servir os arquivos compilados."

