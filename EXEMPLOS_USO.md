# 📖 Exemplos de Uso dos Scripts

Guia prático com cenários reais de uso dos scripts de desenvolvimento.

---

## 🌅 Cenário 1: Primeiro Uso

Você acabou de clonar o repositório e quer rodar pela primeira vez.

```bash
# 1. Dar permissão de execução aos scripts (só precisa fazer uma vez)
chmod +x *.sh

# 2. Iniciar o ambiente
./start-appsmith-dev.sh

# Saída esperada:
# ╔════════════════════════════════════════════════════════════╗
# ║     🚀 Iniciando Ambiente de Desenvolvimento Appsmith     ║
# ╚════════════════════════════════════════════════════════════╝
# [1/6] Verificando dependências...
# ✓ Docker instalado
# ✓ Java instalado
# ✓ Node.js e Yarn instalados
# ...

# 3. Aguardar ~60 segundos (primeira vez demora mais)

# 4. Verificar se está tudo ok
./status-appsmith-dev.sh

# 5. Testar
./test-appsmith-dev.sh

# 6. Acessar
# Abrir no navegador: http://localhost
```

**💡 Dica:** Na primeira execução, o Docker vai baixar imagens MongoDB e Redis (~500MB), então pode demorar.

---

## ☕ Cenário 2: Dia a Dia de Desenvolvimento

Você já usou antes e quer começar a desenvolver hoje.

```bash
# 1. Iniciar (mais rápido pois já tem as imagens)
./start-appsmith-dev.sh

# 2. Enquanto sobe, abrir terminais para logs
# Terminal 1:
tail -f logs/backend.log

# Terminal 2:
tail -f logs/frontend.log

# 3. Abrir IDE e começar a desenvolver
# - Alterações no frontend recarregam automaticamente
# - Alterações no backend precisam recompilar

# 4. Durante o dia, verificar status quando necessário
./status-appsmith-dev.sh

# 5. Ao final do dia
./stop-appsmith-dev.sh
# Quando perguntar sobre MongoDB/Redis, responda 'y' 
# para mantê-los rodando (acelera próximo start)
```

**💡 Dica:** Deixe MongoDB e Redis rodando entre sessões. Eles consomem pouca memória e tornam o próximo start muito mais rápido.

---

## 🔧 Cenário 3: Debugando um Problema

Algo não está funcionando e você precisa investigar.

```bash
# 1. Ver status geral
./status-appsmith-dev.sh

# Saída mostra:
# 🐳 Containers Docker:
#    ✓ appsmith-mongodb - RODANDO
#    ✓ appsmith-redis - RODANDO
#    ✗ wildcard-nginx - NÃO EXISTE  ← Problema aqui!
# ...

# 2. Ver logs do que está com problema
tail -n 100 logs/backend.log  # Últimas 100 linhas

# 3. Procurar por erros específicos
grep -i error logs/backend.log
grep -i exception logs/backend.log

# 4. Se backend não iniciou, verificar MongoDB
docker logs appsmith-mongodb

# 5. Se frontend não carrega, testar backend diretamente
curl http://localhost:8080/api/v1/users/me

# 6. Verificar se RTS está respondendo
curl http://localhost:8091

# 7. Se nada funciona, restart completo
./stop-appsmith-dev.sh
./start-appsmith-dev.sh
```

**💡 Dica:** Use `grep -A 10 -i error logs/backend.log` para ver 10 linhas APÓS cada erro, útil para stack traces.

---

## 🔄 Cenário 4: Mudou Muita Coisa, Quer Reset Total

Você fez muitas mudanças e quer começar do zero limpo.

```bash
# 1. Parar tudo
./stop-appsmith-dev.sh
# Responda 'y' para parar MongoDB e Redis também

# 2. Remover containers (isso apaga os dados!)
docker rm --force appsmith-mongodb appsmith-redis wildcard-nginx

# 3. Remover dados locais
rm -rf data/
rm -rf logs/
rm -rf app/server/container-volumes/

# 4. (Opcional) Limpar node_modules para rebuild completo
rm -rf app/client/node_modules
cd app/client && yarn install

# 5. Iniciar do zero
cd ../..
./start-appsmith-dev.sh

# Agora você tem um ambiente completamente limpo!
```

**⚠️ Atenção:** Isso apaga TODOS os dados (usuários, apps, etc). Faça backup se precisar!

---

## 🧪 Cenário 5: Testando Antes de Fazer PR

Você fez mudanças e quer garantir que tudo funciona antes de abrir um Pull Request.

```bash
# 1. Garantir que está tudo rodando
./start-appsmith-dev.sh

# 2. Aguardar completo startup
sleep 60

# 3. Rodar testes automatizados
./test-appsmith-dev.sh

# Saída esperada:
# ╔════════════════════════════════════════════════════════════╗
# ║         🧪 Testes do Ambiente de Desenvolvimento          ║
# ╚════════════════════════════════════════════════════════════╝
# [1/4] Testando Containers Docker...
# ✓ MongoDB container rodando
# ✓ Redis container rodando
# ...
# ╔════════════════════════════════════════════════════════════╗
# ║  🎉 Todos os testes passaram! (20/20)                     ║
# ╚════════════════════════════════════════════════════════════╝

# 4. Rodar testes do código
cd app/client && yarn test
cd ../server && ./mvnw test

# 5. Verificar lint
cd ../client && yarn lint

# 6. Testar manualmente no navegador
# Abrir http://localhost e testar suas mudanças

# 7. Se tudo ok, fazer commit
git add .
git commit -m "feat: minha feature incrível"
```

**💡 Dica:** Configure um git hook para rodar `./test-appsmith-dev.sh` antes de cada push.

---

## 🐛 Cenário 6: Porta Já em Uso

Você tentou iniciar mas uma porta está ocupada.

```bash
# Tentou iniciar:
./start-appsmith-dev.sh

# Erro:
# ✗ Porta 8080 já está em uso. Tentando parar processo existente...

# 1. Ver o que está usando a porta
lsof -i :8080

# Saída:
# COMMAND   PID    USER   FD   TYPE  DEVICE  SIZE/OFF NODE NAME
# java    12345   user   123u IPv6  0x...   0t0      TCP *:http-alt

# 2. Matar o processo
kill -9 12345

# 3. Ou deixar o script fazer automaticamente
# (ele já tenta fazer isso)

# 4. Iniciar novamente
./start-appsmith-dev.sh

# Se ainda não funcionar, matar tudo na porta:
kill -9 $(lsof -ti :8080)
```

**💡 Dica:** O script `start-appsmith-dev.sh` já tenta liberar as portas automaticamente.

---

## 🚀 Cenário 7: Deploy de Teste Local

Você quer testar como ficaria em produção.

```bash
# 1. Fazer build de produção do frontend
cd app/client
yarn build

# 2. Build do backend
cd ../server
./mvnw clean package -DskipTests

# 3. O build fica em:
# Frontend: app/client/build/
# Backend: app/server/target/appsmith-server-*.jar

# 4. Para rodar o build de produção, você precisaria
# de um servidor nginx apontando para o build/
# Mas para dev, use sempre ./start-appsmith-dev.sh
```

---

## 🔍 Cenário 8: Monitorando em Tempo Real

Você quer ver tudo que está acontecendo.

```bash
# Opção 1: Múltiplos terminais
# Terminal 1:
tail -f logs/backend.log

# Terminal 2:
tail -f logs/rts.log

# Terminal 3:
tail -f logs/frontend.log

# Terminal 4:
watch -n 2 './status-appsmith-dev.sh'

# Opção 2: Um terminal com tmux
tmux new-session \; \
  send-keys 'tail -f logs/backend.log' C-m \; \
  split-window -h \; \
  send-keys 'tail -f logs/rts.log' C-m \; \
  split-window -v \; \
  send-keys 'tail -f logs/frontend.log' C-m \; \
  select-pane -t 0 \; \
  split-window -v \; \
  send-keys 'watch -n 2 ./status-appsmith-dev.sh' C-m

# Opção 3: Todos os logs juntos (pode ficar confuso)
tail -f logs/*.log
```

**💡 Dica:** Use `tmux` ou `screen` para gerenciar múltiplos terminais facilmente.

---

## 💾 Cenário 9: Fazer Backup Antes de Mudanças Arriscadas

Você vai fazer mudanças grandes e quer poder voltar.

```bash
# 1. Parar tudo primeiro
./stop-appsmith-dev.sh

# 2. Criar backup
tar -czf backup_$(date +%Y%m%d_%H%M%S).tar.gz \
  data/ \
  logs/ \
  app/server/container-volumes/

# Saída:
# backup_20231119_143022.tar.gz criado

# 3. Fazer suas mudanças arriscadas
# ... código ...

# 4. Se der errado, restaurar:
tar -xzf backup_20231119_143022.tar.gz

# 5. Iniciar novamente
./start-appsmith-dev.sh
```

**💡 Dica:** Mantenha backups regulares, especialmente antes de mudanças no schema do MongoDB.

---

## 🌙 Cenário 10: Deixar Rodando Durante a Noite

Você quer deixar testes longos rodando durante a noite.

```bash
# 1. Iniciar tudo
./start-appsmith-dev.sh

# 2. Verificar que está ok
./status-appsmith-dev.sh
./test-appsmith-dev.sh

# 3. Iniciar seus testes longos em background
nohup yarn test:e2e > test-results.log 2>&1 &

# 4. Ver o PID
echo $!

# 5. Monitorar de vez em quando
tail -f test-results.log

# 6. Pela manhã, coletar resultados
cat test-results.log

# 7. Parar tudo
./stop-appsmith-dev.sh
```

**⚠️ Atenção:** Certifique-se que sua máquina não vai dormir (configurar Energy Saver no macOS).

---

## 📊 Cenário 11: Performance Testing

Você quer testar performance e ver uso de recursos.

```bash
# 1. Iniciar ambiente
./start-appsmith-dev.sh

# 2. Monitorar recursos dos containers
docker stats

# Saída:
# CONTAINER        CPU %   MEM USAGE / LIMIT    MEM %   NET I/O
# appsmith-mongodb 2.5%    250MiB / 2GiB        12.5%   1MB / 2MB
# appsmith-redis   0.5%    20MiB / 2GiB         1.0%    500KB / 1MB

# 3. Ver uso de CPU/memória do sistema
top -o %MEM

# 4. Ver especificamente processos Java
ps aux | grep java | grep -v grep

# 5. Profiling do backend (requer ferramentas adicionais)
# jvisualvm (instalar separadamente)

# 6. Ver logs de performance
grep -i "slow\|performance\|timeout" logs/backend.log
```

**💡 Dica:** Use ferramentas como `jvisualvm` ou `jconsole` para profiling detalhado do Java.

---

## 🎓 Cenário 12: Ensinar Novo Dev do Time

Um novo dev entrou no time e você quer ensinar o setup.

```bash
# 1. Clonar o repositório
git clone <repo-url>
cd appsmith-inforcfc

# 2. Mostrar documentação
cat INICIO_RAPIDO.md

# 3. Instalar dependências se necessário
# macOS:
brew install docker java node yarn

# 4. Tornar scripts executáveis
chmod +x *.sh

# 5. Primeira execução (vai demorar)
./start-appsmith-dev.sh

# 6. Enquanto aguarda, explicar:
cat DEV_SETUP.md

# 7. Testar
./test-appsmith-dev.sh

# 8. Mostrar comandos úteis
cat COMANDOS_UTEIS.md

# 9. Dar acesso aos logs
tail -f logs/*.log

# 10. Parar ao final
./stop-appsmith-dev.sh
```

**💡 Dica:** Grave um vídeo curto mostrando o processo, facilita onboarding.

---

## 🏃 Resumo Rápido: Comandos Mais Usados

```bash
# Iniciar trabalho do dia
./start-appsmith-dev.sh

# Ver o que está acontecendo
tail -f logs/backend.log

# Checar se tudo ok
./status-appsmith-dev.sh

# Testar antes de PR
./test-appsmith-dev.sh

# Parar ao final do dia
./stop-appsmith-dev.sh

# Reset completo quando necessário
./stop-appsmith-dev.sh
docker rm --force appsmith-mongodb appsmith-redis wildcard-nginx
rm -rf data/ logs/
./start-appsmith-dev.sh
```

---

## 💡 Próximos Passos

- Consulte [COMANDOS_UTEIS.md](COMANDOS_UTEIS.md) para referência completa
- Leia [DEV_SETUP.md](DEV_SETUP.md) para troubleshooting detalhado
- Configure seu IDE com as instruções em `contributions/ServerSetup.md`

**Happy Coding!** 🚀

