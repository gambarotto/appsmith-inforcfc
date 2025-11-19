# 🚀 Setup Rápido do Ambiente de Desenvolvimento Appsmith

Este guia explica como usar os scripts automatizados para subir o ambiente de desenvolvimento do Appsmith com um único comando.

## 📋 Pré-requisitos

Antes de executar os scripts, certifique-se de ter instalado:

- **Docker**: Para rodar MongoDB e Redis
- **Java 17**: OpenJDK 17 para o backend Spring Boot
- **Node.js** (v16+) e **Yarn**: Para o frontend React
- **Maven 3.6+**: Para build do backend

### Verificar instalação

```bash
docker --version
java -version
node --version
yarn --version
mvn --version
```

## 🎯 Início Rápido

### 1. Tornar os scripts executáveis

```bash
chmod +x start-appsmith-dev.sh stop-appsmith-dev.sh
```

### 2. Iniciar o ambiente

```bash
./start-appsmith-dev.sh
```

Este script irá automaticamente:

1. ✅ Verificar todas as dependências necessárias
2. 🐳 Criar e iniciar containers Docker para MongoDB e Redis
3. 🔧 Configurar replica set do MongoDB
4. ⚙️ Configurar todas as variáveis de ambiente
5. 🚀 Iniciar o backend Java/Spring na porta 8080
6. 🔄 Iniciar o RTS (Runtime Service) na porta 8091
7. 💻 Iniciar o frontend React com hot-reload
8. 🌐 Configurar proxy nginx para integrar tudo

### 3. Acessar a aplicação

Aguarde aproximadamente 30-60 segundos para todos os serviços ficarem prontos, então acesse:

**🌐 http://localhost**

## 📊 Monitoramento

### Ver logs em tempo real

```bash
# Backend
tail -f logs/backend.log

# RTS
tail -f logs/rts.log

# Frontend
tail -f logs/frontend.log
```

### Verificar status dos containers

```bash
docker ps
```

Você deve ver:
- `appsmith-mongodb`
- `appsmith-redis`
- `wildcard-nginx`

### Verificar portas em uso

```bash
lsof -i :8080  # Backend
lsof -i :8091  # RTS
lsof -i :3000  # Frontend dev server
lsof -i :80    # Nginx proxy
```

## 🛑 Parar o ambiente

```bash
./stop-appsmith-dev.sh
```

Este script irá:

1. Parar todos os processos (backend, RTS, frontend)
2. Parar o container nginx
3. Perguntar se deseja parar MongoDB e Redis (dados são preservados)

**Nota:** Se você mantiver MongoDB e Redis rodando, na próxima execução do `start-appsmith-dev.sh` eles serão reutilizados, acelerando o startup.

## 🔧 Configurações

### Portas utilizadas

| Serviço | Porta | Descrição |
|---------|-------|-----------|
| MongoDB | 27017 | Banco de dados principal |
| Redis | 6379 | Cache e sessões |
| Backend | 8080 | API REST do Appsmith |
| RTS | 8091 | Runtime Service |
| Frontend Dev | 3000 | Webpack dev server |
| Nginx | 80 | Proxy reverso HTTP |

### Variáveis de ambiente

O script configura automaticamente:

```bash
APPSMITH_MONGODB_URI="mongodb://localhost:27017/appsmith"
APPSMITH_REDIS_URL="redis://localhost:6379"
APPSMITH_GIT_ROOT="<project_root>/app/server/container-volumes/git-storage"
APPSMITH_ENCRYPTION_PASSWORD="password"
APPSMITH_ENCRYPTION_SALT="salt"
SERVER_PORT=8080
```

### Persistência de dados

Os dados do MongoDB são salvos em:
```
<project_root>/data/mongodb/
```

Isso significa que seus dados persistem mesmo após parar/reiniciar o ambiente.

## 🐛 Troubleshooting

### Porta já em uso

Se alguma porta estiver ocupada, o script tentará liberar automaticamente. Se não funcionar:

```bash
# Descobrir o processo usando a porta
lsof -i :8080

# Matar o processo (use o PID que aparecer)
kill -9 <PID>
```

### MongoDB não inicializa replica set

Se o MongoDB não configurar o replica set corretamente:

```bash
# Conectar ao MongoDB
docker exec -it appsmith-mongodb mongosh

# Inicializar manualmente
rs.initiate({"_id": "rs0", "members" : [{"_id":0 , "host": "localhost:27017" }]})
```

### Backend não inicia

Verifique o log:
```bash
tail -f logs/backend.log
```

Certifique-se de que MongoDB e Redis estão rodando:
```bash
docker ps | grep appsmith
```

### Frontend em branco

1. Verifique se o backend está respondendo:
   ```bash
   curl http://localhost:8080/api/v1/users/me
   ```

2. Verifique se o RTS está rodando:
   ```bash
   curl http://localhost:8091/health
   ```

3. Reinicie o proxy nginx:
   ```bash
   docker rm --force wildcard-nginx
   cd app/client && ./start-https.sh --with-docker
   ```

### Limpar tudo e recomeçar

```bash
# Parar todos os serviços
./stop-appsmith-dev.sh

# Remover containers (APAGA OS DADOS!)
docker rm --force appsmith-mongodb appsmith-redis wildcard-nginx

# Remover dados do MongoDB
rm -rf data/

# Limpar logs
rm -rf logs/

# Iniciar novamente
./start-appsmith-dev.sh
```

## 🔄 Desenvolvimento

### Fazer alterações no código

O ambiente está configurado com hot-reload:

- **Frontend**: Qualquer alteração em `app/client/src/` recarrega automaticamente
- **Backend**: Alterações em Java requerem rebuild via IntelliJ ou `mvn compile`
- **RTS**: Reinicie o RTS se fizer alterações (`pkill -f "yarn start" && cd app/client/packages/rts && yarn start`)

### Rodar testes

```bash
# Frontend
cd app/client
yarn test

# Backend
cd app/server
./mvnw test
```

### Build de produção

```bash
# Frontend
cd app/client
yarn build

# Backend
cd app/server
./mvnw clean package -DskipTests
```

## 📚 Recursos Adicionais

- [Guia de Contribuição](contributions/ServerSetup.md)
- [Setup do Client](contributions/ClientSetup.md)
- [Documentação Oficial Appsmith](https://docs.appsmith.com)

## 💡 Dicas

1. **Primeira execução**: A primeira vez demora mais (download de imagens Docker, build do backend)
2. **Desenvolvimento rápido**: Mantenha MongoDB/Redis rodando entre sessões
3. **Logs**: Use `tail -f logs/*.log` para debug em tempo real
4. **Perfomance**: Se o backend estiver lento, aumente a memória do Java editando `app/server/scripts/start-dev-server.sh`

## 🆘 Suporte

Se encontrar problemas:

1. Verifique os logs em `logs/`
2. Consulte a seção de Troubleshooting acima
3. Abra uma issue no repositório

---

**Desenvolvido com ❤️ para a comunidade Appsmith**

