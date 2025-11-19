# 🚀 Início Rápido - Appsmith Development

## ⚡ Setup em 3 Passos

### 1️⃣ Tornar scripts executáveis (apenas primeira vez)

```bash
chmod +x *.sh
```

### 2️⃣ Iniciar o ambiente

```bash
./start-appsmith-dev.sh
```

Este comando irá:
- ✅ Criar containers Docker (MongoDB + Redis)
- ✅ Configurar todas as variáveis de ambiente
- ✅ Iniciar Backend (Spring Boot)
- ✅ Iniciar RTS (Runtime Service)
- ✅ Iniciar Frontend (React)
- ✅ Configurar proxy Nginx

**⏱️ Aguarde ~30-60 segundos** para todos os serviços ficarem prontos.

### 3️⃣ Acessar a aplicação

Abra no navegador:

```
http://localhost
```

---

## 📋 Scripts Disponíveis

| Script | Descrição |
|--------|-----------|
| `./start-appsmith-dev.sh` | Inicia todo o ambiente de desenvolvimento |
| `./stop-appsmith-dev.sh` | Para todos os serviços |
| `./status-appsmith-dev.sh` | Mostra status de todos os serviços |
| `./test-appsmith-dev.sh` | Valida que tudo está funcionando |

---

## 📊 Verificar se está funcionando

```bash
# Ver status
./status-appsmith-dev.sh

# Rodar testes
./test-appsmith-dev.sh

# Ver logs em tempo real
tail -f logs/backend.log
tail -f logs/rts.log
tail -f logs/frontend.log
```

---

## 🔌 Portas Utilizadas

| Serviço | Porta | URL |
|---------|-------|-----|
| MongoDB | 27017 | `mongodb://localhost:27017/appsmith` |
| Redis | 6379 | `redis://localhost:6379` |
| Backend API | 8080 | http://localhost:8080 |
| RTS | 8091 | http://localhost:8091 |
| Frontend Dev | 3000 | http://localhost:3000 |
| **Aplicação** | **80** | **http://localhost** |

---

## 🛑 Parar o Ambiente

```bash
./stop-appsmith-dev.sh
```

O script perguntará se deseja parar MongoDB e Redis também.

**💡 Dica:** Manter MongoDB/Redis rodando acelera a próxima inicialização!

---

## 🐛 Problemas Comuns

### ❌ Porta já em uso

```bash
# Ver o que está usando a porta
lsof -i :8080

# Matar o processo
kill -9 <PID>
```

### ❌ Frontend não carrega

```bash
# Verificar se backend está respondendo
curl http://localhost:8080/api/v1/users/me

# Verificar se RTS está rodando
curl http://localhost:8091

# Reiniciar proxy
docker rm --force wildcard-nginx
cd app/client && ./start-https.sh --with-docker
```

### ❌ "Cannot connect to MongoDB"

```bash
# Verificar se MongoDB está rodando
docker ps | grep mongodb

# Iniciar se estiver parado
docker start appsmith-mongodb

# Verificar replica set
docker exec appsmith-mongodb mongosh --eval "rs.status()"
```

### ❌ Limpar tudo e recomeçar

```bash
./stop-appsmith-dev.sh
docker rm --force appsmith-mongodb appsmith-redis wildcard-nginx
rm -rf data/ logs/
./start-appsmith-dev.sh
```

---

## 📚 Documentação Completa

- **[DEV_SETUP.md](DEV_SETUP.md)** - Guia completo de setup e troubleshooting
- **[COMANDOS_UTEIS.md](COMANDOS_UTEIS.md)** - Referência de todos os comandos úteis
- **[contributions/ServerSetup.md](contributions/ServerSetup.md)** - Setup do backend
- **[contributions/ClientSetup.md](contributions/ClientSetup.md)** - Setup do frontend

---

## 🎯 Desenvolvimento

### Fazer alterações no código

- **Frontend**: Salve o arquivo, hot-reload automático ⚡
- **Backend**: Recompile via IDE ou Maven
- **RTS**: Reinicie o serviço

### Ver logs durante desenvolvimento

```bash
# Abrir em terminais separados
tail -f logs/backend.log
tail -f logs/rts.log
tail -f logs/frontend.log

# Ou tudo junto
tail -f logs/*.log
```

### Rodar testes

```bash
# Frontend
cd app/client && yarn test

# Backend
cd app/server && ./mvnw test
```

---

## 💾 Dados Persistidos

Os dados são salvos em:

```
data/mongodb/                    # Dados do MongoDB
app/server/container-volumes/    # Git storage
logs/                            # Logs dos serviços
```

Esses diretórios são ignorados pelo Git (.gitignore).

---

## ✅ Checklist de Verificação

Após executar `./start-appsmith-dev.sh`, verifique:

- [ ] Containers Docker rodando: `docker ps`
- [ ] Backend respondendo: `curl http://localhost:8080/api/v1/users/me`
- [ ] RTS respondendo: `curl http://localhost:8091`
- [ ] Aplicação acessível: Abrir http://localhost no navegador
- [ ] Sem erros nos logs: `tail logs/*.log`

---

## 🆘 Precisa de Ajuda?

1. Execute: `./status-appsmith-dev.sh`
2. Execute: `./test-appsmith-dev.sh`
3. Veja os logs: `tail -f logs/*.log`
4. Consulte: [DEV_SETUP.md](DEV_SETUP.md) ou [COMANDOS_UTEIS.md](COMANDOS_UTEIS.md)
5. Reinicie: `./stop-appsmith-dev.sh && ./start-appsmith-dev.sh`

---

## 🎉 Pronto para Desenvolver!

Depois que tudo estiver rodando:

1. Acesse http://localhost
2. Crie sua conta ou faça login
3. Comece a desenvolver! 🚀

**Happy Coding!** 💻✨

