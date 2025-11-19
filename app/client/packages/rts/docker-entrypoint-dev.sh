#!/bin/bash

set -e

echo "=============================================="
echo "  🚀 Iniciando RTS (Runtime Service - Dev)"
echo "=============================================="

# Aguardar backend estar pronto
echo "⏳ Aguardando Backend..."
until curl -sf http://backend:8080/api/v1/users/me > /dev/null 2>&1; do
    echo "   Backend não está pronto - aguardando..."
    sleep 3
done
echo "✅ Backend está pronto!"

echo ""
echo "🚀 Iniciando RTS..."
echo "   📍 Porta: 8091"
echo "   🔗 Backend: $APPSMITH_API_BASE_URL"
echo ""

# Iniciar RTS com hot-reload
exec yarn start

