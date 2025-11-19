#!/bin/bash

set -e

echo "=============================================="
echo "  🚀 Iniciando Frontend React (Dev Mode)"
echo "=============================================="

# Aguardar backend e RTS estarem prontos
echo "⏳ Aguardando serviços..."
sleep 10  # Dar tempo para backend e RTS subirem

echo ""
echo "🚀 Iniciando Webpack Dev Server..."
echo "   📍 Porta: 3000"
echo "   🔥 Hot Reload: Ativo"
echo ""

# Iniciar dev server com hot reload
exec yarn start

