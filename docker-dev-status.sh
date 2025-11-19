#!/bin/bash

################################################################################
# Script para Ver Status do Appsmith Docker Compose
################################################################################

# Cores
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         📊 Status do Appsmith Development (Docker)       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BLUE}🐳 Containers:${NC}"
docker compose -f docker-compose.dev.yml ps

echo ""
echo -e "${BLUE}📊 Uso de Recursos:${NC}"
docker stats --no-stream $(docker compose -f docker-compose.dev.yml ps -q 2>/dev/null) 2>/dev/null || echo "Nenhum container rodando"

echo ""
echo -e "${BLUE}💾 Volumes:${NC}"
docker volume ls | grep appsmith-dev || echo "Nenhum volume encontrado"

echo ""
echo -e "${BLUE}🌐 Acessos:${NC}"
echo -e "   Aplicação: ${GREEN}http://localhost${NC}"
echo -e "   Backend:   ${GREEN}http://localhost:8080${NC}"
echo -e "   RTS:       ${GREEN}http://localhost:8091${NC}"
echo -e "   Frontend:  ${GREEN}http://localhost:3000${NC}"

echo ""
echo -e "${BLUE}💡 Comandos Úteis:${NC}"
echo -e "   Ver logs:    ./docker-dev-logs.sh [serviço]"
echo -e "   Parar:       ./docker-dev-stop.sh"
echo -e "   Reiniciar:   docker compose -f docker-compose.dev.yml restart [serviço]"
echo ""

