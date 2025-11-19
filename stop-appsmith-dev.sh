#!/bin/bash

################################################################################
# Script para Parar o Ambiente de Desenvolvimento Appsmith
################################################################################

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="$PROJECT_ROOT/.appsmith-dev-pids"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║        🛑 Parando Ambiente de Desenvolvimento Appsmith    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

################################################################################
# Função: Parar processo por PID
################################################################################
stop_process() {
    local pid=$1
    local name=$2
    
    if [ -z "$pid" ]; then
        return
    fi
    
    if ps -p $pid > /dev/null 2>&1; then
        echo -e "${YELLOW}🛑 Parando $name (PID: $pid)...${NC}"
        kill -15 $pid 2>/dev/null || true
        sleep 2
        
        # Se ainda estiver rodando, força kill
        if ps -p $pid > /dev/null 2>&1; then
            kill -9 $pid 2>/dev/null || true
        fi
        echo -e "${GREEN}✓ $name parado${NC}"
    else
        echo -e "${YELLOW}⚠ $name não está rodando (PID: $pid)${NC}"
    fi
}

################################################################################
# Função: Parar processos por porta
################################################################################
stop_port() {
    local port=$1
    local name=$2
    
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        echo -e "${YELLOW}🛑 Parando $name (porta $port)...${NC}"
        local pids=$(lsof -ti:$port)
        for pid in $pids; do
            kill -9 $pid 2>/dev/null || true
        done
        echo -e "${GREEN}✓ $name parado${NC}"
    fi
}

################################################################################
# Parar processos salvos no arquivo de PIDs
################################################################################
if [ -f "$PID_FILE" ]; then
    echo -e "${BLUE}[1/4] Parando processos via PIDs salvos...${NC}"
    source "$PID_FILE"
    
    stop_process "$BACKEND_PID" "Backend"
    stop_process "$RTS_PID" "RTS"
    stop_process "$FRONTEND_PID" "Frontend"
    
    rm -f "$PID_FILE"
    echo ""
else
    echo -e "${YELLOW}⚠ Arquivo de PIDs não encontrado, tentando por portas...${NC}"
    echo ""
fi

################################################################################
# Garantir que as portas estejam livres
################################################################################
echo -e "${BLUE}[2/4] Verificando portas...${NC}"
stop_port 8080 "Backend (porta 8080)"
stop_port 8091 "RTS (porta 8091)"
stop_port 3000 "Frontend Dev Server (porta 3000)"
echo ""

################################################################################
# Parar containers Docker
################################################################################
echo -e "${BLUE}[3/4] Parando containers Docker...${NC}"

# Parar nginx proxy
if docker ps -a --format '{{.Names}}' | grep -q '^wildcard-nginx$'; then
    echo -e "${YELLOW}🛑 Parando wildcard-nginx...${NC}"
    docker rm --force wildcard-nginx >/dev/null 2>&1
    echo -e "${GREEN}✓ wildcard-nginx parado${NC}"
fi

# Perguntar se deseja parar MongoDB e Redis
echo ""
read -p "$(echo -e ${YELLOW}Deseja parar MongoDB e Redis também? \(dados serão preservados\) [y/N]: ${NC})" -n 1 -r
echo ""

if [[ $REPLY =~ ^[YySs]$ ]]; then
    if docker ps --format '{{.Names}}' | grep -q '^appsmith-mongodb$'; then
        echo -e "${YELLOW}🛑 Parando appsmith-mongodb...${NC}"
        docker stop appsmith-mongodb >/dev/null 2>&1
        echo -e "${GREEN}✓ MongoDB parado${NC}"
    fi
    
    if docker ps --format '{{.Names}}' | grep -q '^appsmith-redis$'; then
        echo -e "${YELLOW}🛑 Parando appsmith-redis...${NC}"
        docker stop appsmith-redis >/dev/null 2>&1
        echo -e "${GREEN}✓ Redis parado${NC}"
    fi
    
    echo ""
    echo -e "${YELLOW}💡 Para remover os containers completamente (apaga dados):${NC}"
    echo -e "   docker rm appsmith-mongodb appsmith-redis"
else
    echo -e "${GREEN}✓ MongoDB e Redis continuam rodando${NC}"
fi

echo ""

################################################################################
# Limpar arquivos temporários
################################################################################
echo -e "${BLUE}[4/4] Limpando arquivos temporários...${NC}"
rm -f "$PID_FILE"
echo -e "${GREEN}✓ Arquivos temporários removidos${NC}"

################################################################################
# Finalização
################################################################################
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║         ✓ Ambiente de desenvolvimento parado!             ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Para reiniciar o ambiente:${NC} ./start-appsmith-dev.sh"
echo ""

exit 0

