# Arquivos de Configuração Kubernetes para Appsmith

Este diretório contém os arquivos YAML para deploy do Appsmith no Kubernetes.

## 📋 Arquivos

- `namespace.yaml` - Namespace do Appsmith
- `frontend-deployment.yaml` - Deployment do frontend (Nginx servindo build estático)
- `frontend-service.yaml` - Service do frontend
- `backend-deployment.yaml` - Deployment do backend (Spring Boot)
- `backend-service.yaml` - Service do backend
- `nginx-configmap.yaml` - ConfigMap com configuração do Nginx
- `ingress.yaml` - Ingress para expor os serviços
- `secrets-example.yaml` - Exemplo de Secrets (NÃO usar em produção)

## 🚀 Como Usar

### 1. Criar Namespace

```bash
kubectl apply -f namespace.yaml
```

### 2. Criar Secrets

**⚠️ IMPORTANTE**: Não use o `secrets-example.yaml` diretamente. Crie os secrets manualmente:

```bash
kubectl create secret generic appsmith-secrets \
  --from-literal=mongodb-uri='mongodb://mongodb:27017/appsmith' \
  --from-literal=encryption-password='SUA_SENHA_FORTE_AQUI' \
  --from-literal=encryption-salt='SEU_SALT_AQUI' \
  -n appsmith
```

### 3. Build da Imagem do Frontend

```bash
cd app/client
docker build -t appsmith-frontend:latest -f Dockerfile.prod .
docker tag appsmith-frontend:latest seu-registry/appsmith-frontend:latest
docker push seu-registry/appsmith-frontend:latest
```

**Nota**: Ajuste o `image` no `frontend-deployment.yaml` para apontar para sua imagem.

### 4. Aplicar ConfigMap do Nginx

```bash
kubectl apply -f nginx-configmap.yaml
```

### 5. Aplicar Deployments e Services

```bash
kubectl apply -f frontend-deployment.yaml
kubectl apply -f frontend-service.yaml
kubectl apply -f backend-deployment.yaml
kubectl apply -f backend-service.yaml
```

### 6. Aplicar Ingress

**⚠️ IMPORTANTE**: Ajuste o `host` no `ingress.yaml` para seu domínio:

```yaml
# Em ingress.yaml, altere:
- host: appsmith.com  # ← Seu domínio aqui
```

Depois aplique:

```bash
kubectl apply -f ingress.yaml
```

## 🔧 Personalizações Necessárias

Antes de aplicar os arquivos, ajuste:

1. **Domínio**: Altere `appsmith.com` para seu domínio em:
   - `ingress.yaml` (host)
   - `backend-deployment.yaml` (APPSMITH_CUSTOM_DOMAIN)

2. **Imagens Docker**: Ajuste as imagens em:
   - `frontend-deployment.yaml` (image: appsmith-frontend:latest)
   - `backend-deployment.yaml` (image: appsmith/appsmith-ce:latest)

3. **Secrets**: Crie os secrets com valores reais (não use o exemplo)

4. **Recursos**: Ajuste `resources` (CPU/memória) conforme necessário

5. **Replicas**: Ajuste `replicas` conforme sua necessidade

## ✅ Verificação

```bash
# Verificar pods
kubectl get pods -n appsmith

# Verificar services
kubectl get svc -n appsmith

# Verificar ingress
kubectl get ingress -n appsmith

# Ver logs do frontend
kubectl logs -f deployment/appsmith-frontend -n appsmith

# Ver logs do backend
kubectl logs -f deployment/appsmith-backend -n appsmith
```

## 🐛 Troubleshooting

### Pods não iniciam

```bash
# Ver eventos
kubectl describe pod <pod-name> -n appsmith

# Ver logs
kubectl logs <pod-name> -n appsmith
```

### Frontend não acessa backend

```bash
# Testar conectividade
kubectl exec -it deployment/appsmith-frontend -n appsmith -- \
  curl http://appsmith-backend:8080/api/v1/health
```

### Verificar configuração do Nginx

```bash
# Ver ConfigMap
kubectl get configmap appsmith-nginx-config -n appsmith -o yaml

# Verificar se está montado no pod
kubectl exec -it deployment/appsmith-frontend -n appsmith -- \
  cat /etc/nginx/conf.d/default.conf
```

