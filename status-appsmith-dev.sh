#!/bin/bash

################################################################################
# Script para Verificar Status do Ambiente de Desenvolvimento Appsmith
################################################################################

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║      📊 Status do Ambiente de Desenvolvimento Appsmith    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

################################################################################
# Função: Verificar porta
################################################################################
check_port() {
    local port=$1
    local name=$2
    
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        local pid=$(lsof -ti:$port | head -n1)
        echo -e "   ${GREEN}✓${NC} $name (porta $port) - ${GREEN}RODANDO${NC} (PID: $pid)"
        return 0
    else
        echo -e "   ${RED}✗${NC} $name (porta $port) - ${RED}PARADO${NC}"
        return 1
    fi
}

################################################################################
# Função: Verificar container Docker
################################################################################
check_container() {
    local name=$1
    
    if docker ps --format '{{.Names}}' | grep -q "^$name$"; then
        local status=$(docker inspect --format='{{.State.Status}}' $name)
        echo -e "   ${GREEN}✓${NC} $name - ${GREEN}RODANDO${NC} (status: $status)"
        return 0
    elif docker ps -a --format '{{.Names}}' | grep -q "^$name$"; then
        echo -e "   ${YELLOW}⚠${NC} $name - ${YELLOW}PARADO${NC}"
        return 1
    else
        echo -e "   ${RED}✗${NC} $name - ${RED}NÃO EXISTE${NC}"
        return 2
    fi
}

################################################################################
# Função: Testar endpoint HTTP
################################################################################
check_endpoint() {
    local url=$1
    local name=$2
    
    if curl -s -o /dev/null -w "%{http_code}" --max-time 3 "$url" | grep -q "200\|302"; then
        echo -e "   ${GREEN}✓${NC} $name - ${GREEN}RESPONDENDO${NC}"
        return 0
    else
        echo -e "   ${RED}✗${NC} $name - ${RED}SEM RESPOSTA${NC}"
        return 1
    fi
}

################################################################################
# Verificar Containers Docker
################################################################################
echo -e "${BLUE}🐳 Containers Docker:${NC}"
check_container "appsmith-mongodb"
check_container "appsmith-redis"
check_container "wildcard-nginx"
echo ""

################################################################################
# Verificar Portas
################################################################################
echo -e "${BLUE}🔌 Portas / Processos:${NC}"
check_port 27017 "MongoDB"
check_port 6379 "Redis"
check_port 8080 "Backend (Spring Boot)"
check_port 8091 "RTS (Runtime Service)"
check_port 3000 "Frontend Dev Server"
check_port 80 "Nginx Proxy"
echo ""

################################################################################
# Verificar Endpoints
################################################################################
echo -e "${BLUE}🌐 Endpoints:${NC}"
check_endpoint "http://localhost:8080/api/v1/users/me" "Backend API"
check_endpoint "http://localhost:8091/health" "RTS Health"
check_endpoint "http://localhost" "Aplicação Principal"
echo ""

################################################################################
# Verificar Logs
################################################################################
echo -e "${BLUE}📝 Logs:${NC}"
if [ -f "$PROJECT_ROOT/logs/backend.log" ]; then
    local size=$(du -h "$PROJECT_ROOT/logs/backend.log" | cut -f1)
    echo -e "   ${GREEN}✓${NC} Backend log: $size"
else
    echo -e "   ${RED}✗${NC} Backend log não encontrado"
fi

if [ -f "$PROJECT_ROOT/logs/rts.log" ]; then
    local size=$(du -h "$PROJECT_ROOT/logs/rts.log" | cut -f1)
    echo -e "   ${GREEN}✓${NC} RTS log: $size"
else
    echo -e "   ${RED}✗${NC} RTS log não encontrado"
fi

if [ -f "$PROJECT_ROOT/logs/frontend.log" ]; then
    local size=$(du -h "$PROJECT_ROOT/logs/frontend.log" | cut -f1)
    echo -e "   ${GREEN}✓${NC} Frontend log: $size"
else
    echo -e "   ${RED}✗${NC} Frontend log não encontrado"
fi
echo ""

################################################################################
# Verificar Dados Persistidos
################################################################################
echo -e "${BLUE}💾 Dados:${NC}"
if [ -d "$PROJECT_ROOT/data/mongodb" ]; then
    local size=$(du -sh "$PROJECT_ROOT/data/mongodb" 2>/dev/null | cut -f1)
    echo -e "   ${GREEN}✓${NC} MongoDB data: $size"
else
    echo -e "   ${YELLOW}⚠${NC} Diretório de dados do MongoDB não existe"
fi

if [ -d "$PROJECT_ROOT/app/server/container-volumes/git-storage" ]; then
    local size=$(du -sh "$PROJECT_ROOT/app/server/container-volumes/git-storage" 2>/dev/null | cut -f1)
    echo -e "   ${GREEN}✓${NC} Git storage: $size"
else
    echo -e "   ${YELLOW}⚠${NC} Diretório git-storage não existe"
fi
echo ""

################################################################################
# Resumo
################################################################################
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"

# Contar quantos serviços estão rodando
services_up=0
services_total=6

lsof -Pi :27017 -sTCP:LISTEN -t >/dev/null 2>&1 && ((services_up++))
lsof -Pi :6379 -sTCP:LISTEN -t >/dev/null 2>&1 && ((services_up++))
lsof -Pi :8080 -sTCP:LISTEN -t >/dev/null 2>&1 && ((services_up++))
lsof -Pi :8091 -sTCP:LISTEN -t >/dev/null 2>&1 && ((services_up++))
lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null 2>&1 && ((services_up++))
lsof -Pi :80 -sTCP:LISTEN -t >/dev/null 2>&1 && ((services_up++))

if [ $services_up -eq $services_total ]; then
    echo -e "${GREEN}║  ✓ Todos os serviços estão rodando ($services_up/$services_total)        ║${NC}"
    echo -e "${GREEN}║  🌐 Aplicação disponível em: http://localhost            ║${NC}"
elif [ $services_up -gt 0 ]; then
    echo -e "${YELLOW}║  ⚠ Alguns serviços estão rodando ($services_up/$services_total)          ║${NC}"
    echo -e "${YELLOW}║  Execute: ./start-appsmith-dev.sh                      ║${NC}"
else
    echo -e "${RED}║  ✗ Nenhum serviço está rodando (0/$services_total)            ║${NC}"
    echo -e "${RED}║  Execute: ./start-appsmith-dev.sh                      ║${NC}"
fi

echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

################################################################################
# Comandos úteis
################################################################################
echo -e "${BLUE}💡 Comandos úteis:${NC}"
echo -e "   Ver logs:        tail -f logs/backend.log"
echo -e "   Iniciar:         ./start-appsmith-dev.sh"
echo -e "   Parar:           ./stop-appsmith-dev.sh"
echo -e "   Verificar:       ./status-appsmith-dev.sh"
echo ""

exit 0

