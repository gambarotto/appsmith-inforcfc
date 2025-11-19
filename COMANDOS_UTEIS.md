# 📚 Comandos Úteis - Desenvolvimento Appsmith

Guia de referência rápida com comandos úteis para desenvolvimento no Appsmith.

## 🚀 Scripts de Gerenciamento

### Iniciar ambiente completo
```bash
./start-appsmith-dev.sh
```
Sobe MongoDB, Redis, Backend, RTS e Frontend com um único comando.

### Parar ambiente
```bash
./stop-appsmith-dev.sh
```
Para todos os serviços. Pergunta se deseja manter MongoDB/Redis rodando.

### Verificar status
```bash
./status-appsmith-dev.sh
```
Mostra o status de todos os serviços e endpoints.

### Executar testes de validação
```bash
./test-appsmith-dev.sh
```
Valida que todos os serviços estão funcionando corretamente.

---

## 📊 Monitoramento

### Ver logs em tempo real

```bash
# Backend (Spring Boot)
tail -f logs/backend.log

# RTS (Runtime Service)
tail -f logs/rts.log

# Frontend (React/Webpack)
tail -f logs/frontend.log

# Todos os logs simultaneamente
tail -f logs/*.log
```

### Filtrar erros nos logs

```bash
# Ver apenas erros no backend
tail -f logs/backend.log | grep -i error

# Ver apenas avisos
tail -f logs/backend.log | grep -i warn

# Ver stack traces
tail -f logs/backend.log | grep -A 10 "Exception"
```

---

## 🐳 Docker

### Verificar containers

```bash
# Listar containers rodando
docker ps

# Listar todos (incluindo parados)
docker ps -a

# Ver apenas Appsmith
docker ps | grep appsmith
```

### Logs de containers

```bash
# MongoDB
docker logs appsmith-mongodb
docker logs -f appsmith-mongodb  # tempo real

# Redis
docker logs appsmith-redis
docker logs -f appsmith-redis    # tempo real

# Nginx
docker logs wildcard-nginx
docker logs -f wildcard-nginx    # tempo real
```

### Conectar aos containers

```bash
# MongoDB shell
docker exec -it appsmith-mongodb mongosh

# Redis CLI
docker exec -it appsmith-redis redis-cli

# Shell do container
docker exec -it appsmith-mongodb bash
```

### Gerenciar containers

```bash
# Parar container
docker stop appsmith-mongodb

# Iniciar container parado
docker start appsmith-mongodb

# Reiniciar container
docker restart appsmith-mongodb

# Remover container (APAGA DADOS!)
docker rm --force appsmith-mongodb
```

---

## 🔌 Verificação de Portas

### Ver o que está usando cada porta

```bash
# MongoDB (27017)
lsof -i :27017

# Redis (6379)
lsof -i :6379

# Backend (8080)
lsof -i :8080

# RTS (8091)
lsof -i :8091

# Frontend Dev (3000)
lsof -i :3000

# Nginx (80)
lsof -i :80
```

### Liberar porta em uso

```bash
# Descobrir PID
lsof -ti :8080

# Matar processo específico
kill -9 <PID>

# Matar todos na porta 8080
kill -9 $(lsof -ti :8080)
```

### Testar conectividade de porta

```bash
# Com netcat
nc -zv localhost 8080

# Com telnet
telnet localhost 8080

# Com curl
curl -v localhost:8080
```

---

## 🗄️ MongoDB

### Conectar ao MongoDB

```bash
# Via Docker
docker exec -it appsmith-mongodb mongosh

# Local (se mongosh instalado)
mongosh mongodb://localhost:27017/appsmith
```

### Comandos úteis no mongosh

```javascript
// Mostrar databases
show dbs

// Usar database appsmith
use appsmith

// Listar coleções
show collections

// Ver usuários
db.user.find().pretty()

// Contar documentos
db.user.countDocuments()

// Ver aplicações
db.application.find().pretty()

// Limpar cache/sessões
db.session.deleteMany({})

// Ver status do replica set
rs.status()

// Ver configuração do replica set
rs.conf()

// Backup de uma coleção
mongoexport --db=appsmith --collection=user --out=users_backup.json

// Restore de uma coleção
mongoimport --db=appsmith --collection=user --file=users_backup.json
```

### Backup completo do MongoDB

```bash
# Backup
docker exec appsmith-mongodb mongodump --archive=/tmp/backup.archive --db=appsmith
docker cp appsmith-mongodb:/tmp/backup.archive ./backup_$(date +%Y%m%d).archive

# Restore
docker cp backup_20231119.archive appsmith-mongodb:/tmp/restore.archive
docker exec appsmith-mongodb mongorestore --archive=/tmp/restore.archive
```

---

## 🔴 Redis

### Conectar ao Redis

```bash
# Via Docker
docker exec -it appsmith-redis redis-cli

# Local (se redis-cli instalado)
redis-cli -h localhost -p 6379
```

### Comandos úteis no Redis

```bash
# Ver todas as chaves
KEYS *

# Contar chaves
DBSIZE

# Ver informações do servidor
INFO

# Ver memória usada
INFO memory

# Limpar TUDO (cuidado!)
FLUSHALL

# Limpar apenas database atual
FLUSHDB

# Ver valor de uma chave
GET nome_da_chave

# Deletar chave
DEL nome_da_chave

# Ver tipo de uma chave
TYPE nome_da_chave

# Ver tempo de expiração
TTL nome_da_chave

# Monitorar comandos em tempo real
MONITOR
```

---

## ⚙️ Backend (Java/Spring Boot)

### Compilar e rodar manualmente

```bash
cd app/server

# Compilar
./mvnw clean compile

# Rodar testes
./mvnw test

# Package (sem testes)
./mvnw clean package -DskipTests

# Rodar com Maven
./mvnw spring-boot:run
```

### Variáveis de ambiente importantes

```bash
export APPSMITH_MONGODB_URI="mongodb://localhost:27017/appsmith"
export APPSMITH_REDIS_URL="redis://localhost:6379"
export APPSMITH_GIT_ROOT="/path/to/git-storage"
export SERVER_PORT=8080
export APPSMITH_ENCRYPTION_PASSWORD="password"
export APPSMITH_ENCRYPTION_SALT="salt"
```

### Testar endpoints do backend

```bash
# Health check
curl http://localhost:8080/actuator/health

# User info (requer autenticação)
curl http://localhost:8080/api/v1/users/me

# Consolidated API
curl http://localhost:8080/api/v1/consolidated-api/view

# Com headers verbose
curl -v http://localhost:8080/api/v1/users/me

# Com formato JSON bonito
curl -s http://localhost:8080/api/v1/users/me | jq .
```

---

## 🎨 Frontend (React)

### Comandos Yarn

```bash
cd app/client

# Instalar dependências
yarn install

# Iniciar dev server
yarn start

# Build de produção
yarn build

# Rodar testes
yarn test

# Lint
yarn lint

# Verificar formatação
yarn prettier --check src/

# Corrigir formatação
yarn prettier --write src/
```

### Limpar cache do Node

```bash
cd app/client

# Limpar cache do Yarn
yarn cache clean

# Remover node_modules e reinstalar
rm -rf node_modules yarn.lock
yarn install
```

### Hot reload não funcionando?

```bash
# Aumentar limite de file watchers (Linux)
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# macOS (não costuma ter esse problema)
# Se tiver, tente reiniciar o dev server
```

---

## 🔄 RTS (Runtime Service)

### Rodar manualmente

```bash
cd app/client/packages/rts

# Criar .env se não existir
cat > .env <<EOF
APPSMITH_API_BASE_URL=http://localhost:8080/api/v1
PORT=8091
HOST=0.0.0.0
NODE_ENV=development
EOF

# Instalar dependências
yarn install

# Iniciar
yarn start

# Build
yarn build
```

### Testar RTS

```bash
# Health check
curl http://localhost:8091/health

# Ver todas as rotas
curl http://localhost:8091/
```

---

## 🌐 Proxy Nginx

### Gerenciar proxy Docker

```bash
cd app/client

# Iniciar com Docker
./start-https.sh --with-docker

# Parar
docker rm --force wildcard-nginx

# Ver logs
docker logs -f wildcard-nginx

# Ver configuração
docker exec wildcard-nginx cat /etc/nginx/nginx.conf
```

### Testar proxy

```bash
# Testar rota raiz
curl http://localhost/

# Testar proxy para API
curl http://localhost/api/v1/users/me

# Testar headers
curl -I http://localhost/

# Seguir redirects
curl -L http://localhost/user/login
```

---

## 🧹 Limpeza e Reset

### Limpar ambiente completamente

```bash
# Parar tudo
./stop-appsmith-dev.sh

# Remover containers (APAGA DADOS!)
docker rm --force appsmith-mongodb appsmith-redis wildcard-nginx

# Remover dados persistidos
rm -rf data/
rm -rf app/server/container-volumes/

# Remover logs
rm -rf logs/

# Limpar node_modules (opcional)
rm -rf app/client/node_modules
rm -rf app/client/packages/*/node_modules

# Reiniciar do zero
./start-appsmith-dev.sh
```

### Reset do MongoDB (mantém container)

```bash
# Conectar ao MongoDB
docker exec -it appsmith-mongodb mongosh

# Dropar database
use appsmith
db.dropDatabase()

# Sair e reiniciar backend
exit
```

### Limpar cache do Redis

```bash
docker exec appsmith-redis redis-cli FLUSHALL
```

---

## 🐛 Debug

### Debug do Backend (Java)

```bash
# Adicionar no start-dev-server.sh ou rodar manualmente:
export JAVA_TOOL_OPTIONS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005"

# Conectar debugger na porta 5005
```

### Debug do Frontend (Chrome DevTools)

1. Abrir http://localhost em Chrome
2. F12 para abrir DevTools
3. Sources → Page → localhost:3000
4. Adicionar breakpoints

### Ver variáveis de ambiente

```bash
# Backend
ps aux | grep java
cat /proc/<PID>/environ | tr '\0' '\n'

# Frontend
ps aux | grep "node.*start.js"

# Todas as variáveis exportadas
export
```

---

## 📦 Performance

### Ver uso de recursos

```bash
# CPU e Memória dos containers
docker stats

# Específico para MongoDB
docker stats appsmith-mongodb

# Processos do sistema
top -o %MEM

# Apenas Java
ps aux | grep java | grep -v grep
```

### Otimizar memória do Java

Editar `app/server/scripts/start-dev-server.sh`:

```bash
# Aumentar heap
export JAVA_OPTS="-Xmx2g -Xms1g"
```

---

## 🔐 Segurança

### Gerar senhas seguras

```bash
# Para ENCRYPTION_PASSWORD
openssl rand -base64 32

# Para ENCRYPTION_SALT
openssl rand -base64 16
```

### Ver configurações de segurança

```bash
# Headers de segurança
curl -I http://localhost/ | grep -i "security\|content-security\|x-frame"
```

---

## 💡 Dicas Rápidas

```bash
# Ver tudo rodando de uma vez
watch -n 2 './status-appsmith-dev.sh'

# Reinício rápido de um serviço
kill -9 $(lsof -ti :8080) && cd app/server && nohup ./scripts/start-dev-server.sh &

# Abrir múltiplos logs em abas separadas (tmux)
tmux new-session \; \
  send-keys 'tail -f logs/backend.log' C-m \; \
  split-window -h \; \
  send-keys 'tail -f logs/rts.log' C-m \; \
  split-window -v \; \
  send-keys 'tail -f logs/frontend.log' C-m

# Fazer backup antes de mudanças arriscadas
./stop-appsmith-dev.sh
tar -czf backup_$(date +%Y%m%d_%H%M%S).tar.gz data/ logs/ app/server/container-volumes/
./start-appsmith-dev.sh
```

---

## 📞 Ajuda

Se precisar de mais ajuda:

1. Verifique os logs: `tail -f logs/*.log`
2. Veja o status: `./status-appsmith-dev.sh`
3. Execute os testes: `./test-appsmith-dev.sh`
4. Consulte a documentação: `cat DEV_SETUP.md`
5. Veja o README principal: `cat README.md`

---

**💡 Dica:** Adicione este arquivo aos seus favoritos para referência rápida durante o desenvolvimento!

