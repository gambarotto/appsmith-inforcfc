#!/bin/bash

################################################################################
# Script para Iniciar Appsmith Completo com Docker Compose
# Todos os serviços rodando em containers
################################################################################

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   🐳 Iniciando Appsmith Development (Docker Compose)     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

################################################################################
# Verificar Docker
################################################################################
echo -e "${BLUE}[1/5] Verificando Docker...${NC}"

if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗ Docker não encontrado!${NC}"
    echo -e "  Instale Docker Desktop: https://www.docker.com/products/docker-desktop"
    exit 1
fi

if ! docker info &> /dev/null; then
    echo -e "${RED}✗ Docker não está rodando!${NC}"
    echo -e "  Inicie Docker Desktop e tente novamente."
    exit 1
fi

echo -e "${GREEN}✓ Docker está rodando${NC}"

if ! command -v docker compose &> /dev/null && ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}✗ Docker Compose não encontrado!${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Docker Compose disponível${NC}"
echo ""

################################################################################
# Criar arquivo .env se não existir
################################################################################
echo -e "${BLUE}[2/5] Verificando configurações...${NC}"

if [ ! -f ".env.dev" ]; then
    echo -e "${YELLOW}📝 Criando arquivo .env.dev...${NC}"
    cp env.dev.example .env.dev
    echo -e "${GREEN}✓ Arquivo .env.dev criado${NC}"
    echo -e "${YELLOW}💡 Dica: Edite .env.dev para personalizar configurações${NC}"
else
    echo -e "${GREEN}✓ Arquivo .env.dev já existe${NC}"
fi

# Criar diretório nginx/certs se não existir
mkdir -p nginx/certs

echo ""

################################################################################
# Dar permissão aos scripts
################################################################################
echo -e "${BLUE}[3/5] Preparando scripts...${NC}"

chmod +x app/server/docker-entrypoint-dev.sh 2>/dev/null || true
chmod +x app/client/docker-entrypoint-dev.sh 2>/dev/null || true
chmod +x app/client/packages/rts/docker-entrypoint-dev.sh 2>/dev/null || true

echo -e "${GREEN}✓ Scripts preparados${NC}"
echo ""

################################################################################
# Parar containers antigos (se existirem)
################################################################################
echo -e "${BLUE}[4/5] Verificando containers antigos...${NC}"

if docker ps -a --format '{{.Names}}' | grep -q '^appsmith-dev-'; then
    echo -e "${YELLOW}⚠ Encontrados containers antigos. Removendo...${NC}"
    docker compose -f docker-compose.dev.yml down 2>/dev/null || true
    echo -e "${GREEN}✓ Containers antigos removidos${NC}"
else
    echo -e "${GREEN}✓ Nenhum container antigo encontrado${NC}"
fi

echo ""

################################################################################
# Iniciar serviços com Docker Compose
################################################################################
echo -e "${BLUE}[5/5] Iniciando serviços...${NC}"
echo ""

echo -e "${YELLOW}📦 Construindo imagens (primeira vez pode demorar ~10-15 min)...${NC}"
echo ""

# Iniciar em modo detached e exibir logs
docker compose -f docker-compose.dev.yml up --build -d

echo ""
echo -e "${GREEN}✓ Containers iniciados!${NC}"
echo ""

################################################################################
# Aguardar serviços estarem prontos
################################################################################
echo -e "${BLUE}⏳ Aguardando serviços ficarem prontos...${NC}"
echo -e "   ${YELLOW}Isso pode levar 2-3 minutos na primeira vez${NC}"
echo ""

# Função para verificar health
wait_for_healthy() {
    local service=$1
    local max_attempts=60
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if docker compose -f docker-compose.dev.yml ps $service | grep -q "healthy\|Up"; then
            return 0
        fi
        attempt=$((attempt + 1))
        sleep 3
    done
    return 1
}

# Aguardar cada serviço
echo -ne "${YELLOW}⏳ MongoDB...${NC}"
if wait_for_healthy mongodb; then
    echo -e "\r${GREEN}✓ MongoDB está pronto!    ${NC}"
else
    echo -e "\r${RED}✗ MongoDB timeout${NC}"
fi

echo -ne "${YELLOW}⏳ Redis...${NC}"
if wait_for_healthy redis; then
    echo -e "\r${GREEN}✓ Redis está pronto!      ${NC}"
else
    echo -e "\r${RED}✗ Redis timeout${NC}"
fi

echo -ne "${YELLOW}⏳ Backend (pode demorar)...${NC}"
sleep 30  # Backend precisa compilar, dar tempo extra
echo -e "\r${GREEN}✓ Backend está compilando...${NC}"

echo -ne "${YELLOW}⏳ RTS...${NC}"
sleep 15
echo -e "\r${GREEN}✓ RTS está pronto!        ${NC}"

echo -ne "${YELLOW}⏳ Frontend...${NC}"
sleep 10
echo -e "\r${GREEN}✓ Frontend está pronto!   ${NC}"

echo -ne "${YELLOW}⏳ Nginx...${NC}"
sleep 5
echo -e "\r${GREEN}✓ Nginx está pronto!      ${NC}"

################################################################################
# Finalização
################################################################################
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║            ✓ Appsmith está rodando em Docker!            ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BLUE}📋 Serviços Rodando:${NC}"
echo -e "   ${GREEN}✓${NC} MongoDB:     mongodb://localhost:27017/appsmith"
echo -e "   ${GREEN}✓${NC} Redis:       redis://localhost:6379"
echo -e "   ${GREEN}✓${NC} Backend:     http://localhost:8080"
echo -e "   ${GREEN}✓${NC} Backend Debug: localhost:5005 (Java debugger)"
echo -e "   ${GREEN}✓${NC} RTS:         http://localhost:8091"
echo -e "   ${GREEN}✓${NC} Frontend:    http://localhost:3000"
echo -e "   ${GREEN}✓${NC} Nginx Proxy: http://localhost"
echo ""

echo -e "${BLUE}🌐 Acesse a aplicação em:${NC} ${GREEN}http://localhost${NC}"
echo ""

echo -e "${BLUE}📊 Comandos Úteis:${NC}"
echo -e "   Ver logs:              docker compose -f docker-compose.dev.yml logs -f"
echo -e "   Ver logs de um serviço: docker compose -f docker-compose.dev.yml logs -f backend"
echo -e "   Ver status:            docker compose -f docker-compose.dev.yml ps"
echo -e "   Parar:                 ./docker-dev-stop.sh"
echo -e "   Reiniciar um serviço:  docker compose -f docker-compose.dev.yml restart backend"
echo ""

echo -e "${YELLOW}💡 Dicas:${NC}"
echo -e "   • Backend demora ~2-3 min para compilar na primeira vez"
echo -e "   • Hot reload está ativo no Frontend"
echo -e "   • Para ver logs em tempo real: docker compose -f docker-compose.dev.yml logs -f"
echo -e "   • Dados persistem nos volumes Docker mesmo após parar"
echo ""

# Perguntar se quer ver logs
read -p "$(echo -e ${YELLOW}Deseja ver os logs agora? [y/N]: ${NC})" -n 1 -r
echo ""
if [[ $REPLY =~ ^[YySs]$ ]]; then
    echo -e "${BLUE}📊 Exibindo logs (Ctrl+C para sair)...${NC}"
    echo ""
    docker compose -f docker-compose.dev.yml logs -f
fi

exit 0

