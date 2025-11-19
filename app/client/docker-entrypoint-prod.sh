#!/bin/bash

set -e

echo "=============================================="
echo "  🚀 Servindo Frontend React (Build Estático)"
echo "=============================================="

echo ""
echo "📦 Servindo arquivos estáticos..."
echo "   📍 Porta: 3000"
echo ""

# Servir o build estático
cd /app/client/build
exec serve -s . -l 3000

