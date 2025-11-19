#!/bin/bash

set -e

echo "=============================================="
echo "  🚀 Iniciando Backend Appsmith (Dev Mode)"
echo "=============================================="

# Aguardar MongoDB estar pronto
echo "⏳ Aguardando MongoDB..."
until curl -s mongodb:27017 > /dev/null 2>&1; do
    echo "   MongoDB não está pronto - aguardando..."
    sleep 2
done
echo "✅ MongoDB está pronto!"

# Aguardar Redis estar pronto
echo "⏳ Aguardando Redis..."
until nc -z redis 6379 > /dev/null 2>&1; do
    echo "   Redis não está pronto - aguardando..."
    sleep 2
done
echo "✅ Redis está pronto!"

echo ""
echo "🔁 Encaminhando localhost:8091 -> rts:8091 ..."
set +e
socat TCP-LISTEN:8091,fork,reuseaddr TCP:rts:8091 &
SOCAT_PID=$!
set -e
trap 'kill "${SOCAT_PID}" 2>/dev/null || true' EXIT
echo "✅ Túnel para o RTS ativo (PID ${SOCAT_PID})"

echo ""
echo "📦 Compilando aplicação..."
cd /app

# Compilar sem rodar testes (para dev é mais rápido)
mvn clean install -DskipTests -B

echo ""
echo "🚀 Iniciando servidor Spring Boot..."
echo "   📍 Porta: 8080"
echo ""

# Iniciar aplicação SEM debug (para evitar conflitos de porta)
exec mvn spring-boot:run -pl appsmith-server -Dspring-boot.run.jvmArguments="-Xmx2g"

