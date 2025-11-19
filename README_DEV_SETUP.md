# 🚀 Appsmith - Guia de Setup para Desenvolvimento

Você tem **DUAS opções** completas e funcionais para rodar o Appsmith localmente:

---

## 🐳 Opção 1: Docker Compose (RECOMENDADO)

**✅ Melhor para:** Onboarding, CI/CD, consistência, isolamento

### Pré-requisitos
- Apenas **Docker Desktop**

### Como usar
```bash
./docker-dev-start.sh
```

### Acesso
```
http://localhost
```

### Documentação
📖 [DOCKER_SETUP.md](DOCKER_SETUP.md) - Guia completo

### Vantagens
✅ Setup em 1 comando  
✅ Não precisa instalar dependências localmente  
✅ Ambiente idêntico em qualquer SO  
✅ Isolamento completo  
✅ Ideal para CI/CD  
✅ Onboarding em minutos  

### Desvantagens
⚠️ ~10% overhead de performance  
⚠️ Primeira build demora ~15min  
⚠️ Backend requer rebuild após mudanças  

---

## 🖥️ Opção 2: Processos Locais

**✅ Melhor para:** Máxima performance, debug nativo

### Pré-requisitos
- Docker Desktop (MongoDB e Redis)
- Java 17 (OpenJDK)
- Node.js 16+
- Yarn
- Maven 3.6+

### Como usar
```bash
./start-appsmith-dev.sh
```

### Acesso
```
http://localhost
```

### Documentação
📖 [DEV_SETUP.md](DEV_SETUP.md) - Guia completo  
📖 [INICIO_RAPIDO.md](INICIO_RAPIDO.md) - Quick start  
📖 [COMANDOS_UTEIS.md](COMANDOS_UTEIS.md) - Referência de comandos  

### Vantagens
✅ Performance nativa  
✅ Debug direto (sem remote)  
✅ Hot reload em tudo  
✅ Acesso direto aos processos  

### Desvantagens
⚠️ Muitas dependências para instalar  
⚠️ Inconsistências entre SOs  
⚠️ Setup inicial mais demorado  
⚠️ Onboarding mais complexo  

---

## 📊 Comparação Rápida

| Critério | 🐳 Docker | 🖥️ Local |
|----------|-----------|----------|
| **Setup inicial** | 1 comando | ~10 comandos |
| **Tempo de setup** | ~15 min | ~30 min |
| **Dependências** | Apenas Docker | Java, Node, Maven, etc |
| **Performance** | 90% nativa | 100% nativa |
| **Isolamento** | ✅ Total | ❌ Nenhum |
| **Portabilidade** | ✅ Perfeita | ⚠️ Varia por SO |
| **Hot Reload** | ✅ Frontend/RTS | ✅ Todos |
| **Debug** | Remote (5005) | Direto |
| **CI/CD** | ✅ Ideal | ⚠️ Complexo |
| **Onboarding** | Minutos | Horas |

---

## 🎯 Qual Escolher?

### Use Docker 🐳 se você:
- É novo no projeto
- Quer ambiente isolado
- Não quer instalar dependências
- Está configurando CI/CD
- Quer garantir consistência no time
- Trabalha em Windows

### Use Local 🖥️ se você:
- Já tem todas as dependências instaladas
- Precisa de máxima performance
- Faz debug intensivo do backend
- Desenvolve features pesadas
- Prefere controle total dos processos

---

## 📁 Estrutura de Arquivos

```
appsmith-inforcfc/
│
├── 🐳 DOCKER COMPOSE
│   ├── docker-compose.dev.yml          # Compose com 6 serviços
│   ├── docker-dev-start.sh             # Inicia Docker
│   ├── docker-dev-stop.sh              # Para Docker
│   ├── docker-dev-status.sh            # Status
│   ├── docker-dev-logs.sh              # Logs
│   ├── app/server/Dockerfile.dev       # Backend
│   ├── app/client/Dockerfile.dev       # Frontend
│   ├── app/client/packages/rts/Dockerfile.dev  # RTS
│   ├── nginx/nginx.dev.conf            # Proxy
│   └── DOCKER_SETUP.md                 # Documentação
│
├── 🖥️ LOCAL (PROCESSOS)
│   ├── start-appsmith-dev.sh           # Inicia local
│   ├── stop-appsmith-dev.sh            # Para local
│   ├── status-appsmith-dev.sh          # Status
│   ├── test-appsmith-dev.sh            # Testes
│   ├── DEV_SETUP.md                    # Documentação completa
│   ├── INICIO_RAPIDO.md                # Quick start
│   ├── COMANDOS_UTEIS.md               # Comandos úteis
│   └── EXEMPLOS_USO.md                 # Exemplos práticos
│
└── 📚 GERAL
    ├── README_DEV_SETUP.md             # Este arquivo
    └── .gitignore                       # Atualizado
```

---

## 🚀 Quick Start

### Docker (Mais Rápido)
```bash
# 1. Instalar Docker Desktop
# 2. Executar
./docker-dev-start.sh
# 3. Aguardar (~15 min primeira vez)
# 4. Acessar http://localhost
```

### Local (Mais Controle)
```bash
# 1. Instalar: Docker, Java 17, Node 16+, Yarn, Maven
# 2. Executar
./start-appsmith-dev.sh
# 3. Aguardar (~3 min)
# 4. Acessar http://localhost
```

---

## 💡 Dicas

### Iniciante no Projeto?
→ Use **Docker** 🐳  
Mais fácil e rápido para começar.

### Desenvolvedor Experiente?
→ Escolha baseado em suas necessidades:
- Performance crítica? → **Local** 🖥️
- Consistência importante? → **Docker** 🐳

### CI/CD?
→ Use **Docker** 🐳  
Containers garantem ambiente idêntico.

### Trabalhando em Feature Complexa?
→ Use **Local** 🖥️ para max performance  
→ Teste final em **Docker** 🐳 antes do PR

---

## 🆘 Suporte

### Docker
```bash
./docker-dev-status.sh        # Ver status
./docker-dev-logs.sh          # Ver logs
cat DOCKER_SETUP.md           # Ler docs
```

### Local
```bash
./status-appsmith-dev.sh      # Ver status
tail -f logs/*.log            # Ver logs
cat DEV_SETUP.md              # Ler docs
cat COMANDOS_UTEIS.md         # Comandos
```

---

## 📚 Documentação Completa

- **Docker:** [DOCKER_SETUP.md](DOCKER_SETUP.md)
- **Local Setup:** [DEV_SETUP.md](DEV_SETUP.md)
- **Quick Start:** [INICIO_RAPIDO.md](INICIO_RAPIDO.md)
- **Comandos Úteis:** [COMANDOS_UTEIS.md](COMANDOS_UTEIS.md)
- **Exemplos:** [EXEMPLOS_USO.md](EXEMPLOS_USO.md)

---

## 🎉 Ambas Funcionam Perfeitamente!

Não há escolha "errada". Ambas as soluções são:
- ✅ Completas
- ✅ Testadas
- ✅ Documentadas
- ✅ Mantidas

Escolha a que melhor se adapta ao seu workflow! 🚀

---

**Happy Coding!** 💻✨

