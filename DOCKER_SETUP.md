# 🐳 Setup com Docker - Appsmith Development

Guia completo para rodar toda a aplicação Appsmith em containers Docker.

---

## ⚡ Início Rápido

### 1. Pré-requisitos

Apenas **Docker Desktop** é necessário!

```bash
# Verificar instalação
docker --version
docker compose version
```

**Download:** https://www.docker.com/products/docker-desktop

### 2. Tornar scripts executáveis

```bash
chmod +x docker-dev-*.sh
```

### 3. Iniciar tudo

```bash
./docker-dev-start.sh
```

**⏱️ Primeira vez:** ~10-15 minutos (build das imagens)  
**Próximas vezes:** ~2-3 minutos (reutiliza imagens)

### 4. Acessar

```
http://localhost
```

---

## 📋 Scripts Disponíveis

| Script | Descrição |
|--------|-----------|
| `./docker-dev-start.sh` | Inicia todos os containers |
| `./docker-dev-stop.sh` | Para os containers |
| `./docker-dev-status.sh` | Mostra status dos containers |
| `./docker-dev-logs.sh` | Ver logs (todos ou específico) |

---

## 🏗️ Arquitetura

```
┌─────────────────────────────────────────────────────────────┐
│                    Docker Compose                            │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────┐   ┌──────────┐   ┌──────────────┐             │
│  │ MongoDB  │   │  Redis   │   │   Backend    │             │
│  │   :27017 │   │   :6379  │   │   (Spring)   │             │
│  │          │   │          │   │   :8080      │             │
│  └──────────┘   └──────────┘   └──────────────┘             │
│                                        │                      │
│  ┌──────────┐   ┌──────────┐   ┌──────────────┐             │
│  │   RTS    │   │ Frontend │   │    Nginx     │             │
│  │  :8091   │   │  (React) │   │ Proxy :80    │◄────────┐  │
│  │          │   │   :3000  │   │              │         │  │
│  └──────────┘   └──────────┘   └──────────────┘         │  │
│                                                           │  │
└───────────────────────────────────────────────────────────┼──┘
                                                            │
                                                     http://localhost
```

---

## 🐳 Serviços

### 1. MongoDB (mongo:5.0)
- **Porta:** 27017
- **Dados:** Volume `appsmith-dev-mongodb-data`
- **Replica Set:** rs0 (auto-configurado)

### 2. Redis (redis:6-alpine)
- **Porta:** 6379
- **Dados:** Volume `appsmith-dev-redis-data`

### 3. Backend (Maven + OpenJDK 17)
- **Porta:** 8080 (API)
- **Debug:** 5005 (Java debugger)
- **Build:** Maven compile na inicialização
- **Cache:** Volume `appsmith-dev-maven-cache`

### 4. RTS - Runtime Service (Node 16)
- **Porta:** 8091
- **Hot Reload:** Sim (via volumes)

### 5. Frontend (Node 16 + React)
- **Porta:** 3000
- **Hot Reload:** Sim (webpack-dev-server)
- **WebSocket:** HMR ativo

### 6. Nginx (nginx:alpine)
- **Porta:** 80 (HTTP)
- **Função:** Proxy reverso
- **Rotas:**
  - `/` → Frontend
  - `/api/` → Backend
  - `/rts/` → RTS

---

## 📊 Comandos Docker Compose

### Ver status
```bash
docker compose -f docker-compose.dev.yml ps
```

### Ver logs

```bash
# Todos os serviços
docker compose -f docker-compose.dev.yml logs -f

# Serviço específico
docker compose -f docker-compose.dev.yml logs -f backend
docker compose -f docker-compose.dev.yml logs -f frontend
docker compose -f docker-compose.dev.yml logs -f rts
```

### Reiniciar serviço

```bash
# Reiniciar backend
docker compose -f docker-compose.dev.yml restart backend

# Rebuild e reiniciar
docker compose -f docker-compose.dev.yml up -d --build backend
```

### Parar/Iniciar

```bash
# Parar
docker compose -f docker-compose.dev.yml stop

# Iniciar (containers existentes)
docker compose -f docker-compose.dev.yml start

# Parar e remover
docker compose -f docker-compose.dev.yml down
```

### Entrar em um container

```bash
# Backend
docker compose -f docker-compose.dev.yml exec backend bash

# MongoDB
docker compose -f docker-compose.dev.yml exec mongodb mongosh

# Redis
docker compose -f docker-compose.dev.yml exec redis redis-cli
```

---

## 💾 Volumes e Persistência

### Volumes criados:

- `appsmith-dev-mongodb-data` - Dados do MongoDB
- `appsmith-dev-redis-data` - Dados do Redis  
- `appsmith-dev-git-storage` - Git storage do Appsmith
- `appsmith-dev-maven-cache` - Cache do Maven (.m2)
- `appsmith-dev-client-node-modules` - node_modules do frontend
- `appsmith-dev-rts-node-modules` - node_modules do RTS

### Listar volumes

```bash
docker volume ls | grep appsmith-dev
```

### Backup de volume

```bash
# Exemplo: Backup do MongoDB
docker run --rm \
  -v appsmith-dev-mongodb-data:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/mongodb-backup.tar.gz -C /data .
```

### Remover volumes (APAGA DADOS!)

```bash
docker compose -f docker-compose.dev.yml down -v
```

---

## 🔧 Desenvolvimento

### Hot Reload

**Frontend (React):** ✅ Automático  
**RTS:** ✅ Automático  
**Backend:** ❌ Requer rebuild

### Modificar código

#### Frontend ou RTS
1. Edite os arquivos normalmente
2. Salve
3. Aguarde hot-reload (~2-5s)

#### Backend
1. Edite os arquivos
2. Rebuild do container:
```bash
docker compose -f docker-compose.dev.yml up -d --build backend
```

Ou compile dentro do container:
```bash
docker compose -f docker-compose.dev.yml exec backend mvn compile
```

### Debug do Backend

O backend expõe porta 5005 para debug.

**IntelliJ IDEA:**
1. Run → Edit Configurations
2. Add → Remote JVM Debug
3. Host: `localhost`
4. Port: `5005`
5. Click Debug

**VS Code:**
```json
{
  "type": "java",
  "request": "attach",
  "name": "Attach to Backend",
  "hostName": "localhost",
  "port": 5005
}
```

---

## 🐛 Troubleshooting

### Containers não iniciam

```bash
# Ver logs de erro
docker compose -f docker-compose.dev.yml logs

# Rebuild forçado
docker compose -f docker-compose.dev.yml build --no-cache
docker compose -f docker-compose.dev.yml up -d
```

### Backend não compila

```bash
# Entrar no container
docker compose -f docker-compose.dev.yml exec backend bash

# Compilar manualmente
cd /app
mvn clean install -DskipTests
```

### Frontend não carrega

```bash
# Verificar se webpack iniciou
docker compose -f docker-compose.dev.yml logs frontend

# Reiniciar frontend
docker compose -f docker-compose.dev.yml restart frontend
```

### MongoDB replica set não configurado

```bash
# Conectar ao MongoDB
docker compose -f docker-compose.dev.yml exec mongodb mongosh

# Inicializar manualmente
rs.initiate({"_id": "rs0", "members" : [{"_id":0 , "host": "mongodb:27017" }]})
```

### Porta já em uso

```bash
# Descobrir o que está usando
lsof -i :80
lsof -i :8080

# Matar processo
kill -9 <PID>

# Ou mudar porta no docker-compose.dev.yml
# ports:
#   - "8081:8080"  # Usar 8081 no host
```

### Limpar tudo e recomeçar

```bash
# Parar e remover tudo
docker compose -f docker-compose.dev.yml down -v

# Remover imagens
docker compose -f docker-compose.dev.yml down --rmi all

# Rebuild completo
./docker-dev-start.sh
```

---

## ⚡ Performance

### Build mais rápido

```bash
# Usar cache do Maven local
volumes:
  - ~/.m2:/root/.m2:cached  # Adicionar no docker-compose.dev.yml
```

### Recursos do Docker

Aumente recursos no Docker Desktop:
- **CPU:** 4-6 cores
- **RAM:** 8-12 GB
- **Disk:** 60+ GB

Settings → Resources → ajustar

### Otimizar node_modules

Os volumes nomeados para `node_modules` evitam lentidão do bind mount no macOS/Windows.

---

## 📊 Monitoramento

### Uso de recursos em tempo real

```bash
docker stats
```

### Healthchecks

Todos os serviços têm healthchecks configurados:

```bash
docker compose -f docker-compose.dev.yml ps
# Coluna "Status" mostra health
```

### Logs estruturados

```bash
# Backend (Spring Boot)
docker compose -f docker-compose.dev.yml logs backend | grep ERROR

# Frontend (webpack)
docker compose -f docker-compose.dev.yml logs frontend | grep compiled
```

---

## 🔒 Segurança

### Variáveis de ambiente

Edite `env.dev.example` e copie para `.env.dev`:

```bash
cp env.dev.example .env.dev
# Editar .env.dev com senhas seguras
```

**IMPORTANTE:** `.env.dev` está no `.gitignore`, nunca commite!

### Portas expostas

Por padrão, todas as portas estão em `localhost` (127.0.0.1):

```yaml
ports:
  - "127.0.0.1:8080:8080"  # Apenas local
  - "8080:8080"            # Expõe na rede
```

---

## 🎯 Comparação: Docker vs Local

| Aspecto | Docker | Local (scripts .sh) |
|---------|--------|---------------------|
| Setup inicial | ~15 min | ~30 min |
| Dependências | Apenas Docker | Java, Node, Maven, etc |
| Isolamento | ✅ Completo | ❌ Usa sistema |
| Hot reload | ✅ Funciona | ✅ Funciona |
| Performance | ~10% mais lento | Nativo |
| Portabilidade | ✅ Muito fácil | ⚠️ Depende do SO |
| Debug | ✅ Remote debug | ✅ Direct |
| Recomendado para | Produção-like, CI/CD | Performance máxima |

---

## 💡 Dicas

1. **Primeira execução:**
   - Vai demorar (~15min para build)
   - Imagens ficam cacheadas
   - Próximas vezes são rápidas

2. **Desenvolvimento:**
   - Mantenha containers rodando entre sessões
   - Use `docker compose restart <serviço>` para reiniciar específico
   - Frontend/RTS têm hot-reload

3. **Dados:**
   - Dados persistem mesmo parando containers
   - Use `down -v` apenas para reset completo

4. **Logs:**
   - Use `./docker-dev-logs.sh` para facilitar
   - `-f` segue logs em tempo real
   - Sem `-f` mostra histórico

5. **Performance:**
   - Aumente RAM do Docker Desktop
   - Use volumes nomeados (já configurado)
   - Bind mounts são lentos no macOS/Windows

---

## 🆘 Precisa de Ajuda?

1. Ver status: `./docker-dev-status.sh`
2. Ver logs: `./docker-dev-logs.sh`
3. Consultar: `docker compose -f docker-compose.dev.yml ps`
4. Reiniciar: `./docker-dev-stop.sh && ./docker-dev-start.sh`

---

## 📚 Documentação Adicional

- [Docker Compose Docs](https://docs.docker.com/compose/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Docker Volumes](https://docs.docker.com/storage/volumes/)

---

**Desenvolvido com ❤️ usando Docker 🐳**

