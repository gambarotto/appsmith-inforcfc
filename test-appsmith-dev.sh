#!/bin/bash

################################################################################
# Script de Teste do Ambiente de Desenvolvimento Appsmith
# Valida que todos os serviços estão funcionando corretamente
################################################################################

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         🧪 Testes do Ambiente de Desenvolvimento          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

TESTS_PASSED=0
TESTS_FAILED=0

################################################################################
# Função: Executar teste
################################################################################
run_test() {
    local test_name=$1
    local test_command=$2
    
    echo -ne "${YELLOW}⏳ Testando: $test_name...${NC}"
    
    if eval "$test_command" >/dev/null 2>&1; then
        echo -e "\r${GREEN}✓ $test_name${NC}"
        ((TESTS_PASSED++))
        return 0
    else
        echo -e "\r${RED}✗ $test_name${NC}"
        ((TESTS_FAILED++))
        return 1
    fi
}

################################################################################
# Testes de Containers Docker
################################################################################
echo -e "${BLUE}[1/4] Testando Containers Docker...${NC}"
run_test "MongoDB container rodando" "docker ps | grep -q appsmith-mongodb"
run_test "Redis container rodando" "docker ps | grep -q appsmith-redis"
run_test "MongoDB réplica set configurado" "docker exec appsmith-mongodb mongosh --quiet --eval 'rs.status().ok' | grep -q 1"
echo ""

################################################################################
# Testes de Conectividade
################################################################################
echo -e "${BLUE}[2/4] Testando Conectividade...${NC}"
run_test "MongoDB escutando porta 27017" "nc -z localhost 27017"
run_test "Redis escutando porta 6379" "nc -z localhost 6379"
run_test "Backend escutando porta 8080" "nc -z localhost 8080"
run_test "RTS escutando porta 8091" "nc -z localhost 8091"
run_test "Frontend dev escutando porta 3000" "nc -z localhost 3000"
run_test "Nginx escutando porta 80" "nc -z localhost 80"
echo ""

################################################################################
# Testes de API
################################################################################
echo -e "${BLUE}[3/4] Testando APIs...${NC}"

# Teste Backend - health
if run_test "Backend responde (health)" "curl -sf http://localhost:8080/api/v1/users/me"; then
    # Se passou, testa estrutura JSON
    run_test "Backend retorna JSON válido" "curl -sf http://localhost:8080/api/v1/users/me | python3 -m json.tool"
fi

# Teste RTS
run_test "RTS responde" "curl -sf http://localhost:8091"

# Teste aplicação principal
run_test "Aplicação principal responde" "curl -sf http://localhost/"
run_test "Aplicação retorna HTML" "curl -sf http://localhost/ | grep -q '<html'"

# Teste proxy para API
run_test "Proxy encaminha para API" "curl -sf http://localhost/api/v1/users/me"

echo ""

################################################################################
# Testes de Arquivos
################################################################################
echo -e "${BLUE}[4/4] Testando Estrutura de Arquivos...${NC}"
run_test "Diretório de dados MongoDB existe" "test -d data/mongodb"
run_test "Diretório git-storage existe" "test -d app/server/container-volumes/git-storage"
run_test "Arquivo .env RTS existe" "test -f app/client/packages/rts/.env"
run_test "Diretório de logs existe" "test -d logs"
run_test "Log do backend existe" "test -f logs/backend.log"
run_test "Log do RTS existe" "test -f logs/rts.log"

echo ""

################################################################################
# Resumo
################################################################################
TOTAL_TESTS=$((TESTS_PASSED + TESTS_FAILED))
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}║  🎉 Todos os testes passaram! ($TESTS_PASSED/$TOTAL_TESTS)                  ║${NC}"
    echo -e "${GREEN}║  ✓ Ambiente está funcionando corretamente                ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${GREEN}🌐 Acesse: http://localhost${NC}"
    echo ""
    exit 0
else
    PERCENTAGE=$((TESTS_PASSED * 100 / TOTAL_TESTS))
    echo -e "${YELLOW}║  ⚠ Alguns testes falharam                                ║${NC}"
    echo -e "${YELLOW}║  ✓ Passaram: $TESTS_PASSED/$TOTAL_TESTS ($PERCENTAGE%)                            ║${NC}"
    echo -e "${YELLOW}║  ✗ Falharam: $TESTS_FAILED/$TOTAL_TESTS                                    ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}💡 Dicas:${NC}"
    echo -e "   • Aguarde mais tempo para os serviços iniciarem (~30-60s)"
    echo -e "   • Verifique os logs: tail -f logs/*.log"
    echo -e "   • Veja o status: ./status-appsmith-dev.sh"
    echo -e "   • Reinicie se necessário: ./stop-appsmith-dev.sh && ./start-appsmith-dev.sh"
    echo ""
    exit 1
fi

