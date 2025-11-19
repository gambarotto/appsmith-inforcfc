#!/bin/bash

################################################################################
# Script de Inicialização do Ambiente de Desenvolvimento Appsmith
# 
# Este script automatiza todo o processo de setup:
# - Inicia MongoDB e Redis via Docker
# - Configura variáveis de ambiente
# - Inicia o servidor backend (Java/Spring)
# - Inicia o RTS (Runtime Service)
# - Inicia o frontend com proxy nginx
################################################################################

set -e  # Aborta em caso de erro

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Diretório raiz do projeto
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SERVER_DIR="$PROJECT_ROOT/app/server"
CLIENT_DIR="$PROJECT_ROOT/app/client"
RTS_DIR="$CLIENT_DIR/packages/rts"

# Configurações
MONGO_PORT=27017
REDIS_PORT=6379
BACKEND_PORT=8080
RTS_PORT=8091
FRONTEND_PORT=80

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     🚀 Iniciando Ambiente de Desenvolvimento Appsmith     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

################################################################################
# Função: Verificar se uma porta está em uso
################################################################################
check_port() {
    local port=$1
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        return 0  # Porta em uso
    else
        return 1  # Porta livre
    fi
}

################################################################################
# Função: Aguardar serviço estar disponível
################################################################################
wait_for_service() {
    local host=$1
    local port=$2
    local service=$3
    local max_attempts=30
    local attempt=0

    echo -e "${YELLOW}⏳ Aguardando $service estar disponível em $host:$port...${NC}"
    
    while [ $attempt -lt $max_attempts ]; do
        if nc -z $host $port 2>/dev/null; then
            echo -e "${GREEN}✓ $service está pronto!${NC}"
            return 0
        fi
        attempt=$((attempt + 1))
        sleep 2
    done
    
    echo -e "${RED}✗ Timeout aguardando $service${NC}"
    return 1
}

################################################################################
# Passo 1: Verificar dependências
################################################################################
echo -e "${BLUE}[1/6] Verificando dependências...${NC}"

# Verificar Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗ Docker não encontrado. Por favor, instale o Docker primeiro.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Docker instalado${NC}"

# Verificar Java
if ! command -v java &> /dev/null; then
    echo -e "${RED}✗ Java não encontrado. Por favor, instale OpenJDK 17.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Java instalado${NC}"

# Verificar Node/Yarn
if ! command -v node &> /dev/null || ! command -v yarn &> /dev/null; then
    echo -e "${RED}✗ Node.js ou Yarn não encontrado.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Node.js e Yarn instalados${NC}"

# Verificar netcat
if ! command -v nc &> /dev/null; then
    echo -e "${YELLOW}⚠ netcat não encontrado. Instalando via Homebrew...${NC}"
    brew install netcat 2>/dev/null || echo -e "${YELLOW}Não foi possível instalar netcat automaticamente${NC}"
fi

################################################################################
# Passo 2: Iniciar MongoDB e Redis via Docker
################################################################################
echo ""
echo -e "${BLUE}[2/6] Configurando MongoDB e Redis...${NC}"

# Criar diretório para dados do MongoDB
MONGO_DATA_DIR="$PROJECT_ROOT/data/mongodb"
mkdir -p "$MONGO_DATA_DIR"

# Verificar e iniciar MongoDB
if docker ps -a --format '{{.Names}}' | grep -q '^appsmith-mongodb$'; then
    if docker ps --format '{{.Names}}' | grep -q '^appsmith-mongodb$'; then
        echo -e "${GREEN}✓ MongoDB já está rodando${NC}"
    else
        echo -e "${YELLOW}↻ Iniciando container MongoDB existente...${NC}"
        docker start appsmith-mongodb
    fi
else
    echo -e "${YELLOW}🔧 Criando e iniciando MongoDB...${NC}"
    docker run -d \
        -p 127.0.0.1:$MONGO_PORT:27017 \
        --name appsmith-mongodb \
        --hostname=localhost \
        -e MONGO_INITDB_DATABASE=appsmith \
        -v "$MONGO_DATA_DIR:/data/db" \
        mongo:5.0 --replSet rs0
    
    # Aguardar MongoDB estar pronto
    wait_for_service "127.0.0.1" $MONGO_PORT "MongoDB"
    
    # Inicializar replica set
    echo -e "${YELLOW}🔧 Inicializando replica set do MongoDB...${NC}"
    sleep 3
    docker exec appsmith-mongodb mongosh --eval 'rs.initiate({"_id": "rs0", "members" : [{"_id":0 , "host": "localhost:27017" }]})'
fi

# Verificar e iniciar Redis
if docker ps -a --format '{{.Names}}' | grep -q '^appsmith-redis$'; then
    if docker ps --format '{{.Names}}' | grep -q '^appsmith-redis$'; then
        echo -e "${GREEN}✓ Redis já está rodando${NC}"
    else
        echo -e "${YELLOW}↻ Iniciando container Redis existente...${NC}"
        docker start appsmith-redis
    fi
else
    echo -e "${YELLOW}🔧 Criando e iniciando Redis...${NC}"
    docker run -d \
        -p 127.0.0.1:$REDIS_PORT:6379 \
        --name appsmith-redis \
        redis:6-alpine
fi

wait_for_service "127.0.0.1" $REDIS_PORT "Redis"

################################################################################
# Passo 3: Configurar variáveis de ambiente
################################################################################
echo ""
echo -e "${BLUE}[3/6] Configurando variáveis de ambiente...${NC}"

# Criar diretório para git storage
GIT_STORAGE_DIR="$SERVER_DIR/container-volumes/git-storage"
mkdir -p "$GIT_STORAGE_DIR"

# Variáveis de ambiente para o servidor
export APPSMITH_MONGODB_URI="mongodb://localhost:$MONGO_PORT/appsmith"
export APPSMITH_REDIS_URL="redis://localhost:$REDIS_PORT"
export APPSMITH_GIT_ROOT="$GIT_STORAGE_DIR"
export APPSMITH_ENCRYPTION_PASSWORD="password"
export APPSMITH_ENCRYPTION_SALT="salt"
export APPSMITH_IS_SELF_HOSTED="false"
export SERVER_PORT=$BACKEND_PORT

echo -e "${GREEN}✓ Variáveis de ambiente configuradas${NC}"
echo -e "   MongoDB: $APPSMITH_MONGODB_URI"
echo -e "   Redis: $APPSMITH_REDIS_URL"
echo -e "   Git Storage: $APPSMITH_GIT_ROOT"

################################################################################
# Passo 4: Configurar e iniciar RTS
################################################################################
echo ""
echo -e "${BLUE}[4/6] Configurando RTS (Runtime Service)...${NC}"

# Criar .env para RTS se não existir
RTS_ENV_FILE="$RTS_DIR/.env"
if [ ! -f "$RTS_ENV_FILE" ]; then
    echo -e "${YELLOW}🔧 Criando arquivo .env para RTS...${NC}"
    cat > "$RTS_ENV_FILE" <<EOF
# RTS Configuration
APPSMITH_API_BASE_URL=http://localhost:$BACKEND_PORT/api/v1
PORT=$RTS_PORT
HOST=0.0.0.0
NODE_ENV=development
EOF
    echo -e "${GREEN}✓ Arquivo .env do RTS criado${NC}"
else
    echo -e "${GREEN}✓ Arquivo .env do RTS já existe${NC}"
fi

################################################################################
# Passo 5: Iniciar Backend
################################################################################
echo ""
echo -e "${BLUE}[5/6] Iniciando Backend (Spring Boot)...${NC}"

# Verificar se o backend já está rodando
if check_port $BACKEND_PORT; then
    echo -e "${YELLOW}⚠ Porta $BACKEND_PORT já está em uso. Tentando parar processo existente...${NC}"
    PID=$(lsof -ti:$BACKEND_PORT)
    if [ ! -z "$PID" ]; then
        kill -9 $PID 2>/dev/null || true
        sleep 2
    fi
fi

# Criar arquivo de log para o backend
BACKEND_LOG="$PROJECT_ROOT/logs/backend.log"
mkdir -p "$PROJECT_ROOT/logs"

echo -e "${YELLOW}🚀 Iniciando servidor backend em background...${NC}"
cd "$SERVER_DIR"

# Iniciar backend em background e redirecionar output para log
nohup ./scripts/start-dev-server.sh > "$BACKEND_LOG" 2>&1 &
BACKEND_PID=$!

echo -e "${GREEN}✓ Backend iniciado (PID: $BACKEND_PID)${NC}"
echo -e "   Log: $BACKEND_LOG"
echo -e "   Para ver logs em tempo real: tail -f $BACKEND_LOG"

# Aguardar backend estar disponível
wait_for_service "localhost" $BACKEND_PORT "Backend"

################################################################################
# Passo 6: Iniciar RTS
################################################################################
echo ""
echo -e "${BLUE}[6/7] Iniciando RTS...${NC}"

# Verificar se RTS já está rodando
if check_port $RTS_PORT; then
    echo -e "${YELLOW}⚠ Porta $RTS_PORT já está em uso. Tentando parar processo existente...${NC}"
    PID=$(lsof -ti:$RTS_PORT)
    if [ ! -z "$PID" ]; then
        kill -9 $PID 2>/dev/null || true
        sleep 2
    fi
fi

# Criar arquivo de log para RTS
RTS_LOG="$PROJECT_ROOT/logs/rts.log"

echo -e "${YELLOW}🚀 Iniciando RTS em background...${NC}"
cd "$RTS_DIR"

# Iniciar RTS em background
nohup yarn start > "$RTS_LOG" 2>&1 &
RTS_PID=$!

echo -e "${GREEN}✓ RTS iniciado (PID: $RTS_PID)${NC}"
echo -e "   Log: $RTS_LOG"

# Aguardar RTS estar disponível
wait_for_service "localhost" $RTS_PORT "RTS"

################################################################################
# Passo 7: Iniciar Frontend com Proxy
################################################################################
echo ""
echo -e "${BLUE}[7/7] Iniciando Frontend com Proxy...${NC}"

cd "$CLIENT_DIR"

# Parar nginx anterior se existir
if docker ps -a --format '{{.Names}}' | grep -q '^wildcard-nginx$'; then
    echo -e "${YELLOW}↻ Parando container nginx anterior...${NC}"
    docker rm --force wildcard-nginx >/dev/null 2>&1
fi

# Verificar se yarn start já está rodando
if check_port 3000; then
    echo -e "${GREEN}✓ Dev server do client já está rodando na porta 3000${NC}"
else
    # Criar arquivo de log para frontend
    FRONTEND_LOG="$PROJECT_ROOT/logs/frontend.log"
    
    echo -e "${YELLOW}🚀 Iniciando dev server do frontend em background...${NC}"
    nohup yarn start > "$FRONTEND_LOG" 2>&1 &
    FRONTEND_PID=$!
    
    echo -e "${GREEN}✓ Frontend iniciado (PID: $FRONTEND_PID)${NC}"
    echo -e "   Log: $FRONTEND_LOG"
    
    # Aguardar frontend estar disponível
    wait_for_service "localhost" 3000 "Frontend Dev Server"
fi

# Iniciar proxy nginx via Docker
echo -e "${YELLOW}🔧 Iniciando proxy nginx...${NC}"
./start-https.sh --with-docker

################################################################################
# Finalização
################################################################################
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              ✓ Appsmith está pronto para uso!             ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}📋 Serviços rodando:${NC}"
echo -e "   ${GREEN}✓${NC} MongoDB:     mongodb://localhost:$MONGO_PORT/appsmith"
echo -e "   ${GREEN}✓${NC} Redis:       redis://localhost:$REDIS_PORT"
echo -e "   ${GREEN}✓${NC} Backend:     http://localhost:$BACKEND_PORT"
echo -e "   ${GREEN}✓${NC} RTS:         http://localhost:$RTS_PORT"
echo -e "   ${GREEN}✓${NC} Frontend:    http://localhost (porta $FRONTEND_PORT)"
echo ""
echo -e "${BLUE}🌐 Acesse a aplicação em:${NC} ${GREEN}http://localhost${NC}"
echo ""
echo -e "${BLUE}📊 Logs em tempo real:${NC}"
echo -e "   Backend:  tail -f $BACKEND_LOG"
echo -e "   RTS:      tail -f $RTS_LOG"
echo -e "   Frontend: tail -f $FRONTEND_LOG"
echo ""
echo -e "${BLUE}🛑 Para parar todos os serviços:${NC}"
echo -e "   ./stop-appsmith-dev.sh"
echo ""
echo -e "${YELLOW}💡 Dica:${NC} Se a aplicação não carregar, aguarde ~30s para o backend finalizar o startup."
echo ""

# Salvar PIDs para script de stop
cat > "$PROJECT_ROOT/.appsmith-dev-pids" <<EOF
BACKEND_PID=$BACKEND_PID
RTS_PID=$RTS_PID
FRONTEND_PID=${FRONTEND_PID:-}
EOF

exit 0

