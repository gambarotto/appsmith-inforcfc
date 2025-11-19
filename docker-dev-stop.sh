#!/bin/bash

################################################################################
# Script para Parar Appsmith Docker Compose
################################################################################

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       🛑 Parando Appsmith Development (Docker)           ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Verificar se há containers rodando
if ! docker compose -f docker-compose.dev.yml ps 2>/dev/null | grep -q "Up"; then
    echo -e "${YELLOW}⚠ Nenhum container Appsmith está rodando${NC}"
    exit 0
fi

echo -e "${BLUE}Parando containers...${NC}"
docker compose -f docker-compose.dev.yml stop

echo ""
read -p "$(echo -e ${YELLOW}Deseja remover os containers? (dados serão preservados) [y/N]: ${NC})" -n 1 -r
echo ""

if [[ $REPLY =~ ^[YySs]$ ]]; then
    echo -e "${BLUE}Removendo containers...${NC}"
    docker compose -f docker-compose.dev.yml down
    echo -e "${GREEN}✓ Containers removidos${NC}"
else
    echo -e "${GREEN}✓ Containers parados (use 'docker compose -f docker-compose.dev.yml start' para reiniciar)${NC}"
fi

echo ""
read -p "$(echo -e ${YELLOW}Deseja remover os volumes? (APAGA TODOS OS DADOS!) [y/N]: ${NC})" -n 1 -r
echo ""

if [[ $REPLY =~ ^[YySs]$ ]]; then
    echo -e "${RED}⚠ ATENÇÃO: Isso vai apagar TODOS os dados (MongoDB, etc)${NC}"
    read -p "$(echo -e ${RED}Tem certeza? Digite 'SIM' para confirmar: ${NC})" confirmation
    
    if [ "$confirmation" = "SIM" ]; then
        echo -e "${BLUE}Removendo volumes...${NC}"
        docker compose -f docker-compose.dev.yml down -v
        echo -e "${GREEN}✓ Volumes removidos${NC}"
    else
        echo -e "${YELLOW}✓ Volumes preservados${NC}"
    fi
else
    echo -e "${GREEN}✓ Volumes preservados${NC}"
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              ✓ Appsmith parado com sucesso!               ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BLUE}Para iniciar novamente:${NC} ./docker-dev-start.sh"
echo ""

exit 0

