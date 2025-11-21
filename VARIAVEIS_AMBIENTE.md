# Variáveis de Ambiente - Appsmith Kubernetes

## 📋 Resumo Rápido

### Frontend (Build Time)

Variáveis que começam com `REACT_APP_` são injetadas no código durante o build.

```bash
# Opcional: Se não usar proxy reverso no Nginx
REACT_APP_BACKEND_URL=https://api.appsmith.com

# Opcional: URL do RTS (Runtime Service)
REACT_APP_RTS_URL=https://rts.appsmith.com

# Opcional: Configurações de logging
REACT_APP_CLIENT_LOG_LEVEL=error  # debug | error

# Opcional: Integrações
REACT_APP_SENTRY_DSN=...
REACT_APP_SENTRY_ENVIRONMENT=production
REACT_APP_SENTRY_RELEASE=...
```

**⚠️ IMPORTANTE**: Se você usar Nginx com proxy reverso (recomendado), **NÃO precisa** definir `REACT_APP_BACKEND_URL`, pois o Nginx fará o proxy automaticamente.

---

### Backend (Runtime)

#### 🔴 Obrigatórias

```bash
# URL base da aplicação (CRÍTICO para CORS e cookies)
APPSMITH_CUSTOM_DOMAIN=https://appsmith.com

# MongoDB
APPSMITH_MONGODB_URI=mongodb://mongodb:27017/appsmith

# Redis
APPSMITH_REDIS_URL=redis://redis:6379

# Encryption (gerar valores fortes)
APPSMITH_ENCRYPTION_PASSWORD=<senha_forte>
APPSMITH_ENCRYPTION_SALT=<salt_aleatorio>
```

#### 🟡 Recomendadas

```bash
# Desabilitar telemetria
APPSMITH_DISABLE_TELEMETRY=true

# Email (se usar)
APPSMITH_MAIL_ENABLED=true
APPSMITH_MAIL_HOST=smtp.gmail.com
APPSMITH_MAIL_PORT=587
APPSMITH_MAIL_USERNAME=...
APPSMITH_MAIL_PASSWORD=...
APPSMITH_MAIL_FROM=...

# OAuth (se usar)
APPSMITH_OAUTH2_GOOGLE_CLIENT_ID=...
APPSMITH_OAUTH2_GOOGLE_CLIENT_SECRET=...
```

#### 🟢 Opcionais

```bash
# Performance
JAVA_OPTS=-Xmx1g -Xms512m

# Logging
APPSMITH_LOG_LEVEL=INFO

# Features
APPSMITH_DISABLE_IFRAME_WIDGET_SANDBOX=false
```

---

## 🔐 Como Gerar Secrets

### Encryption Password e Salt

```bash
# Gerar password forte (32+ caracteres)
openssl rand -base64 32

# Gerar salt (32+ caracteres)
openssl rand -base64 32
```

### Criar Secret no Kubernetes

```bash
kubectl create secret generic appsmith-secrets \
  --from-literal=mongodb-uri='mongodb://mongodb:27017/appsmith' \
  --from-literal=encryption-password='$(openssl rand -base64 32)' \
  --from-literal=encryption-salt='$(openssl rand -base64 32)' \
  -n appsmith
```

---

## 📝 Exemplo Completo de Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: appsmith-backend
spec:
  template:
    spec:
      containers:
      - name: backend
        env:
        # OBRIGATÓRIAS
        - name: APPSMITH_CUSTOM_DOMAIN
          value: "https://appsmith.com"
        - name: APPSMITH_MONGODB_URI
          valueFrom:
            secretKeyRef:
              name: appsmith-secrets
              key: mongodb-uri
        - name: APPSMITH_REDIS_URL
          value: "redis://appsmith-redis:6379"
        - name: APPSMITH_ENCRYPTION_PASSWORD
          valueFrom:
            secretKeyRef:
              name: appsmith-secrets
              key: encryption-password
        - name: APPSMITH_ENCRYPTION_SALT
          valueFrom:
            secretKeyRef:
              name: appsmith-secrets
              key: encryption-salt
        
        # RECOMENDADAS
        - name: APPSMITH_DISABLE_TELEMETRY
          value: "true"
        - name: JAVA_OPTS
          value: "-Xmx1g -Xms512m"
```

---

## ✅ Checklist

- [ ] `APPSMITH_CUSTOM_DOMAIN` configurado com o domínio completo (com https://)
- [ ] `APPSMITH_MONGODB_URI` apontando para o MongoDB
- [ ] `APPSMITH_REDIS_URL` apontando para o Redis
- [ ] `APPSMITH_ENCRYPTION_PASSWORD` gerado e armazenado em Secret
- [ ] `APPSMITH_ENCRYPTION_SALT` gerado e armazenado em Secret
- [ ] Secrets criados no Kubernetes (não usar valores em plain text)
- [ ] Frontend buildado (se necessário, com `REACT_APP_BACKEND_URL`)
- [ ] Nginx configurado para fazer proxy reverso (recomendado)

---

## 🔍 Verificação

### Verificar variáveis no pod

```bash
# Backend
kubectl exec deployment/appsmith-backend -n appsmith -- env | grep APPSMITH

# Frontend (se necessário)
kubectl exec deployment/appsmith-frontend -n appsmith -- env | grep REACT_APP
```

### Verificar secrets

```bash
# Listar secrets
kubectl get secrets -n appsmith

# Ver detalhes (sem valores)
kubectl describe secret appsmith-secrets -n appsmith
```

---

## 📚 Referências

- [Appsmith Environment Variables](https://docs.appsmith.com/advanced-concepts/environment-variables)
- [Kubernetes Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)

