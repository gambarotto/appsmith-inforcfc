#!/bin/bash

################################################################################
# Script para Iniciar Frontend Localmente (sem Docker)
#
# Pré-requisitos:
# - Backend, MongoDB, Redis e RTS devem estar rodando (via Docker ou localmente)
# - Node.js e Yarn instalados
################################################################################

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        🚀 Iniciando Frontend Localmente (React)           ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Diretório do frontend
CLIENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/app/client" && pwd)"

################################################################################
# Verificar dependências
################################################################################
echo -e "${BLUE}[1/4] Verificando dependências...${NC}"

# Verificar Node.js
if ! command -v node &> /dev/null; then
    echo -e "${RED}✗ Node.js não encontrado!${NC}"
    echo -e "  Instale Node.js: https://nodejs.org/"
    exit 1
fi
NODE_VERSION=$(node --version)
echo -e "${GREEN}✓ Node.js instalado: ${NODE_VERSION}${NC}"

# Verificar Yarn
if ! command -v yarn &> /dev/null; then
    echo -e "${RED}✗ Yarn não encontrado!${NC}"
    echo -e "  Instale Yarn: npm install -g yarn"
    exit 1
fi
YARN_VERSION=$(yarn --version)
echo -e "${GREEN}✓ Yarn instalado: ${YARN_VERSION}${NC}"

echo ""

################################################################################
# Verificar se backend está rodando
################################################################################
echo -e "${BLUE}[2/4] Verificando serviços backend...${NC}"

check_service() {
    local host=$1
    local port=$2
    local service=$3

    if nc -z $host $port 2>/dev/null; then
        echo -e "${GREEN}✓ ${service} está rodando em ${host}:${port}${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠ ${service} não está respondendo em ${host}:${port}${NC}"
        return 1
    fi
}

BACKEND_OK=false
RTS_OK=false

if check_service localhost 8080 "Backend"; then
    BACKEND_OK=true
fi

if check_service localhost 8091 "RTS"; then
    RTS_OK=true
fi

if [ "$BACKEND_OK" = false ] || [ "$RTS_OK" = false ]; then
    echo ""
    echo -e "${YELLOW}⚠ Atenção: Alguns serviços não estão rodando!${NC}"
    echo -e "${YELLOW}   Certifique-se de que o backend está rodando antes de continuar.${NC}"
    echo ""
    echo -e "${BLUE}Para iniciar o backend, execute:${NC}"
    echo -e "   ${GREEN}./docker-dev-start-no-frontend.sh${NC}"
    echo ""
    read -p "$(echo -e ${YELLOW}Deseja continuar mesmo assim? [y/N]: ${NC})" -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[YySs]$ ]]; then
        echo -e "${YELLOW}Cancelado. Inicie o backend primeiro.${NC}"
        exit 1
    fi
fi

echo ""

################################################################################
# Verificar e instalar dependências
################################################################################
echo -e "${BLUE}[3/4] Verificando dependências do projeto...${NC}"

cd "$CLIENT_DIR"

if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}📦 Instalando dependências (isso pode demorar alguns minutos)...${NC}"
    yarn install
    echo -e "${GREEN}✓ Dependências instaladas${NC}"
else
    echo -e "${GREEN}✓ Dependências já instaladas${NC}"
    echo -e "${YELLOW}💡 Dica: Execute 'yarn install' se adicionar novas dependências${NC}"
fi

echo ""

################################################################################
# Configurar variáveis de ambiente
################################################################################
echo -e "${BLUE}[4/4] Configurando variáveis de ambiente...${NC}"

# Variáveis de ambiente para o frontend
export REACT_APP_BACKEND_URL="${REACT_APP_BACKEND_URL:-http://localhost:8080}"
export REACT_APP_RTS_URL="${REACT_APP_RTS_URL:-http://localhost:8091}"
export REACT_APP_ENVIRONMENT="DEVELOPMENT"
export REACT_APP_CLIENT_LOG_LEVEL="debug"
export PORT="${PORT:-3000}"
export BROWSER=none

echo -e "${GREEN}✓ Variáveis configuradas:${NC}"
echo -e "   ${GREEN}•${NC} Backend URL: ${REACT_APP_BACKEND_URL}"
echo -e "   ${GREEN}•${NC} RTS URL: ${REACT_APP_RTS_URL}"
echo -e "   ${GREEN}•${NC} Porta: ${PORT}"
echo ""

################################################################################
# Iniciar o frontend
################################################################################
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║            🚀 Iniciando Frontend React...                  ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BLUE}📋 Informações:${NC}"
echo -e "   ${GREEN}•${NC} Frontend rodará em: ${GREEN}http://localhost:${PORT}${NC}"
echo -e "   ${GREEN}•${NC} Hot Reload: ${GREEN}Ativo${NC}"
echo -e "   ${GREEN}•${NC} Modo: ${GREEN}Desenvolvimento${NC}"
echo ""
echo -e "${YELLOW}💡 Dicas:${NC}"
echo -e "   • Pressione ${GREEN}Ctrl+C${NC} para parar o servidor"
echo -e "   • Alterações no código recarregam automaticamente"
echo -e "   • Verifique os logs abaixo para erros"
echo ""

# Iniciar o servidor de desenvolvimento
echo -e "${BLUE}🚀 Iniciando Webpack Dev Server...${NC}"
echo ""

yarn start

