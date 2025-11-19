#!/bin/bash

################################################################################
# Script para Ver Logs do Appsmith Docker Compose
################################################################################

# Cores
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║            📊 Logs do Appsmith Development               ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

if [ -z "$1" ]; then
    echo "📋 Mostrando logs de todos os serviços (Ctrl+C para sair)"
    echo ""
    docker compose -f docker-compose.dev.yml logs -f
else
    echo "📋 Mostrando logs de: $1 (Ctrl+C para sair)"
    echo ""
    docker compose -f docker-compose.dev.yml logs -f "$1"
fi

