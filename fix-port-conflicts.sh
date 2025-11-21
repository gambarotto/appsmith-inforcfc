#!/bin/bash

# Script para resolver conflitos de portas do Docker
# Verifica e para containers que estão usando as portas necessárias

set -e

echo "🔍 Verificando conflitos de portas..."

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função para verificar se uma porta está em uso
check_port() {
    local port=$1
    local service=$2
    
    if lsof -i :$port >/dev/null 2>&1; then
        echo -e "${YELLOW}⚠️  Porta $port ($service) está em uso${NC}"
        lsof -i :$port | grep -v COMMAND
        return 1
    else
        echo -e "${GREEN}✅ Porta $port ($service) está livre${NC}"
        return 0
    fi
}

# Função para parar containers que estão usando uma porta
stop_container_on_port() {
    local port=$1
    local service=$2
    
    echo -e "\n${YELLOW}Procurando containers usando a porta $port...${NC}"
    
    # Encontrar containers usando a porta
    local containers=$(docker ps --format "{{.Names}}" --filter "publish=$port")
    
    if [ -z "$containers" ]; then
        echo -e "${GREEN}Nenhum container Docker usando a porta $port${NC}"
        return 0
    fi
    
    echo -e "${YELLOW}Containers encontrados usando a porta $port:${NC}"
    echo "$containers"
    
    read -p "Deseja parar esses containers? (s/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Ss]$ ]]; then
        echo "$containers" | while read container; do
            echo -e "${YELLOW}Parando container: $container${NC}"
            docker stop "$container" 2>/dev/null || true
        done
        echo -e "${GREEN}✅ Containers parados${NC}"
        return 0
    else
        echo -e "${RED}❌ Containers não foram parados. Você precisará parar manualmente ou usar portas diferentes.${NC}"
        return 1
    fi
}

# Verificar portas necessárias
PORTS=(
    "27017:MongoDB"
    "6379:Redis"
    "8080:Backend"
    "8091:RTS"
    "3000:Frontend"
    "80:Nginx"
)

conflicts=0

echo -e "\n📋 Verificando portas necessárias para o Appsmith:\n"

for port_info in "${PORTS[@]}"; do
    IFS=':' read -r port service <<< "$port_info"
    if ! check_port "$port" "$service"; then
        conflicts=$((conflicts + 1))
    fi
done

if [ $conflicts -eq 0 ]; then
    echo -e "\n${GREEN}✅ Todas as portas estão livres!${NC}"
    exit 0
fi

echo -e "\n${YELLOW}⚠️  Encontrados $conflicts conflito(s) de porta${NC}\n"

# Resolver conflitos
for port_info in "${PORTS[@]}"; do
    IFS=':' read -r port service <<< "$port_info"
    if ! check_port "$port" "$service" 2>/dev/null; then
        stop_container_on_port "$port" "$service"
    fi
done

echo -e "\n${GREEN}✅ Verificação concluída!${NC}"
echo -e "\n💡 Dica: Se ainda houver conflitos, você pode:"
echo "   1. Parar containers manualmente: docker stop <container-name>"
echo "   2. Modificar as portas no docker-compose.dev.yml"
echo "   3. Usar outro ambiente Docker Compose"

