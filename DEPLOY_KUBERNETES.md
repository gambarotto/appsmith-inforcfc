# Deploy do Appsmith no Kubernetes - Frontend e Backend Separados

Este guia explica como configurar o Appsmith para produção no Kubernetes, com o frontend e backend em locais diferentes.

## 📋 Índice

1. [Visão Geral](#visão-geral)
2. [Arquitetura](#arquitetura)
3. [Variáveis de Ambiente](#variáveis-de-ambiente)
4. [Build do Frontend](#build-do-frontend)
5. [Configuração do Kubernetes](#configuração-do-kubernetes)
6. [Configuração do Nginx](#configuração-do-nginx)
7. [CORS e CSRF](#cors-e-csrf)
8. [Cookies e Sessões](#cookies-e-sessões)
9. [Exemplo Completo](#exemplo-completo)

---

## 🎯 Visão Geral

Em produção, o frontend do Appsmith é um **build estático** (HTML, CSS, JS). Diferente do desenvolvimento onde o `setupProxy.js` funciona, em produção você precisa:

1. **Opção 1**: Configurar a URL do backend no build do frontend (via variáveis de ambiente)
2. **Opção 2**: Usar um servidor web (Nginx) que faça proxy reverso para o backend

**Recomendação**: Use a Opção 2 (Nginx com proxy reverso) para maior flexibilidade e melhor performance.

---

## 🏗️ Arquitetura

```
┌─────────────────────────────────────────────────────────────┐
│                         Kubernetes                           │
│                                                               │
│  ┌──────────────────┐         ┌──────────────────┐         │
│  │   Frontend Pod   │         │   Backend Pod    │         │
│  │   (Nginx)        │────────▶│   (Spring Boot)  │         │
│  │   Porta: 80      │  Proxy  │   Porta: 8080    │         │
│  └──────────────────┘         └──────────────────┘         │
│         │                                │                    │
│         └────────────────┬────────────────┘                   │
│                          │                                    │
│                  ┌───────▼────────┐                          │
│                  │  Ingress       │                          │
│                  │  (app.example.com)                        │
│                  └────────────────┘                          │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔧 Variáveis de Ambiente

### Frontend (Build Time)

As variáveis de ambiente do frontend devem ser definidas **durante o build** (não em runtime). Variáveis que começam com `REACT_APP_` são injetadas no código durante o build.

#### Variáveis Essenciais

```bash
# URL do backend (usado apenas se não usar proxy reverso)
REACT_APP_BACKEND_URL=https://api.appsmith.com

# URL do RTS (Runtime Service) - opcional
REACT_APP_RTS_URL=https://rts.appsmith.com

# Outras configurações opcionais
REACT_APP_CLIENT_LOG_LEVEL=error
REACT_APP_SENTRY_DSN=...
REACT_APP_SENTRY_ENVIRONMENT=production
```

**⚠️ IMPORTANTE**: O `setupProxy.js` **NÃO funciona em produção** (só funciona com webpack-dev-server). Em produção, você precisa:

1. **Usar Nginx com proxy reverso** (recomendado), ou
2. **Configurar `REACT_APP_BACKEND_URL` no build** e modificar o `Api.ts` para usar essa URL

### Backend (Runtime)

```bash
# URL base da aplicação (importante para CORS e cookies)
APPSMITH_CUSTOM_DOMAIN=https://appsmith.com

# Ou separadamente:
APPSMITH_FRONTEND_URL=https://appsmith.com
APPSMITH_BACKEND_URL=https://api.appsmith.com

# MongoDB
APPSMITH_MONGODB_URI=mongodb://mongodb:27017/appsmith

# Redis
APPSMITH_REDIS_URL=redis://redis:6379

# Outras configurações
APPSMITH_ENCRYPTION_PASSWORD=...
APPSMITH_ENCRYPTION_SALT=...
APPSMITH_DISABLE_TELEMETRY=true
```

---

## 📦 Build do Frontend

### Dockerfile de Produção

O `Dockerfile.prod` já existe e faz o build estático:

```dockerfile
FROM node:20-alpine

WORKDIR /app
COPY . .
RUN yarn install --immutable

# Definir variáveis de ambiente ANTES do build
ENV REACT_APP_BACKEND_URL=https://api.appsmith.com
ENV NODE_ENV=production

# Build de produção
RUN yarn build

# Instalar servidor HTTP simples
RUN yarn global add serve

EXPOSE 3000
CMD ["serve", "-s", "build", "-l", "3000"]
```

### Build com Variáveis de Ambiente

```bash
# Build local com variáveis
REACT_APP_BACKEND_URL=https://api.appsmith.com \
NODE_ENV=production \
yarn build

# Ou usando docker build
docker build \
  --build-arg REACT_APP_BACKEND_URL=https://api.appsmith.com \
  -t appsmith-frontend:latest \
  -f Dockerfile.prod .
```

**⚠️ Nota**: Se você usar Nginx com proxy reverso, não precisa definir `REACT_APP_BACKEND_URL`, pois o Nginx fará o proxy.

---

## ☸️ Configuração do Kubernetes

### 1. Namespace

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: appsmith
```

### 2. ConfigMap para Frontend (se necessário)

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: appsmith-frontend-config
  namespace: appsmith
data:
  # Se não usar proxy reverso, você precisaria injetar isso no build
  # Por isso, recomendamos usar Nginx com proxy reverso
  REACT_APP_BACKEND_URL: "https://api.appsmith.com"
```

### 3. Deployment do Frontend

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: appsmith-frontend
  namespace: appsmith
spec:
  replicas: 2
  selector:
    matchLabels:
      app: appsmith-frontend
  template:
    metadata:
      labels:
        app: appsmith-frontend
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: frontend-static
          mountPath: /usr/share/nginx/html
        - name: nginx-config
          mountPath: /etc/nginx/conf.d
          readOnly: true
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
      volumes:
      - name: frontend-static
        # Opção 1: Volume de um build estático
        emptyDir: {}
        # Opção 2: Usar initContainer para copiar arquivos
      - name: nginx-config
        configMap:
          name: appsmith-nginx-config
      initContainers:
      - name: build-frontend
        image: appsmith-frontend:latest
        command: ["sh", "-c"]
        args:
        - |
          cp -r /app/build/* /shared/
        volumeMounts:
        - name: frontend-static
          mountPath: /shared
```

### 4. Service do Frontend

```yaml
apiVersion: v1
kind: Service
metadata:
  name: appsmith-frontend
  namespace: appsmith
spec:
  selector:
    app: appsmith-frontend
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
  type: ClusterIP
```

### 5. Deployment do Backend

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: appsmith-backend
  namespace: appsmith
spec:
  replicas: 2
  selector:
    matchLabels:
      app: appsmith-backend
  template:
    metadata:
      labels:
        app: appsmith-backend
    spec:
      containers:
      - name: backend
        image: appsmith/appsmith-ce:latest
        ports:
        - containerPort: 8080
        env:
        - name: APPSMITH_CUSTOM_DOMAIN
          value: "https://appsmith.com"
        - name: APPSMITH_MONGODB_URI
          valueFrom:
            secretKeyRef:
              name: appsmith-secrets
              key: mongodb-uri
        - name: APPSMITH_REDIS_URL
          value: "redis://appsmith-redis:6379"
        resources:
          requests:
            memory: "1Gi"
            cpu: "500m"
          limits:
            memory: "2Gi"
            cpu: "1000m"
```

### 6. Service do Backend

```yaml
apiVersion: v1
kind: Service
metadata:
  name: appsmith-backend
  namespace: appsmith
spec:
  selector:
    app: appsmith-backend
  ports:
  - port: 8080
    targetPort: 8080
    protocol: TCP
  type: ClusterIP
```

### 7. Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: appsmith-ingress
  namespace: appsmith
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    # Importante para CORS
    nginx.ingress.kubernetes.io/enable-cors: "true"
    nginx.ingress.kubernetes.io/cors-allow-origin: "https://appsmith.com"
    nginx.ingress.kubernetes.io/cors-allow-credentials: "true"
spec:
  tls:
  - hosts:
    - appsmith.com
    secretName: appsmith-tls
  rules:
  - host: appsmith.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: appsmith-frontend
            port:
              number: 80
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: appsmith-backend
            port:
              number: 8080
      - path: /oauth2
        pathType: Prefix
        backend:
          service:
            name: appsmith-backend
            port:
              number: 8080
      - path: /login
        pathType: Prefix
        backend:
          service:
            name: appsmith-backend
            port:
              number: 8080
```

---

## 🌐 Configuração do Nginx

### ConfigMap do Nginx

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: appsmith-nginx-config
  namespace: appsmith
data:
  default.conf: |
    server {
        listen 80;
        server_name _;
        root /usr/share/nginx/html;
        index index.html;

        # Gzip
        gzip on;
        gzip_vary on;
        gzip_min_length 1024;
        gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/json;

        # Servir arquivos estáticos
        location / {
            try_files $uri $uri/ /index.html;
            
            # Cache para assets estáticos
            location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
                expires 1y;
                add_header Cache-Control "public, immutable";
            }
        }

        # Proxy para API
        location /api/ {
            proxy_pass http://appsmith-backend:8080/api/;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            
            # Headers importantes para CSRF
            proxy_set_header X-Appsmith-Version $http_x_appsmith_version;
            proxy_set_header X-Requested-By $http_x_requested_by;
            
            # Timeouts
            proxy_connect_timeout 60s;
            proxy_send_timeout 60s;
            proxy_read_timeout 60s;
            
            # Buffering
            proxy_buffering off;
        }

        # Proxy para OAuth2
        location /oauth2/ {
            proxy_pass http://appsmith-backend:8080/oauth2/;
            proxy_http_version 1.1;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Appsmith-Version $http_x_appsmith_version;
            proxy_set_header X-Requested-By $http_x_requested_by;
        }

        # Proxy para Login
        location /login {
            proxy_pass http://appsmith-backend:8080/login;
            proxy_http_version 1.1;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Appsmith-Version $http_x_appsmith_version;
            proxy_set_header X-Requested-By $http_x_requested_by;
        }

        # Health check
        location /health {
            access_log off;
            return 200 "healthy\n";
            add_header Content-Type text/plain;
        }
    }
```

---

## 🔒 CORS e CSRF

### CORS no Backend

O backend precisa estar configurado para aceitar requisições do frontend:

```bash
# No backend, definir:
APPSMITH_CUSTOM_DOMAIN=https://appsmith.com
# ou
APPSMITH_FRONTEND_URL=https://appsmith.com
```

### CSRF

O backend do Appsmith ignora CSRF quando:

1. Header `X-Appsmith-Version` está presente (e não é 'UNKNOWN')
2. Header `X-Requested-By: Appsmith` está presente
3. `Content-Type: application/json` está presente

O Nginx já está configurado para passar esses headers (veja a configuração acima).

### Headers no Frontend

O `Api.ts` já está configurado corretamente:

```typescript
export const apiRequestConfig = {
  baseURL: "/api/",  // Relativo - será resolvido pelo proxy
  withCredentials: true,  // Importante para cookies
};
```

---

## 🍪 Cookies e Sessões

### Configuração de Cookies

O backend precisa configurar cookies corretamente:

```bash
# No backend
APPSMITH_CUSTOM_DOMAIN=https://appsmith.com
```

Isso garante que os cookies sejam configurados com:
- `Domain=.appsmith.com` (ou o domínio correto)
- `Path=/`
- `SameSite=Lax` (ou `None` se usar subdomínios diferentes)
- `Secure=true` (se usar HTTPS)

### Ajuste no Nginx (se necessário)

Se você tiver problemas com cookies, pode ajustar no Nginx:

```nginx
# No location /api/
proxy_cookie_path / /;
proxy_cookie_domain appsmith-backend appsmith.com;
```

---

## 📝 Exemplo Completo

### 1. Build da Imagem do Frontend

```bash
# Build com variáveis de ambiente (opcional se usar proxy reverso)
cd app/client
docker build \
  --build-arg REACT_APP_BACKEND_URL=https://api.appsmith.com \
  -t appsmith-frontend:latest \
  -f Dockerfile.prod .
```

### 2. Aplicar Configurações no Kubernetes

```bash
# Criar namespace
kubectl create namespace appsmith

# Aplicar ConfigMap do Nginx
kubectl apply -f nginx-configmap.yaml -n appsmith

# Aplicar Deployments
kubectl apply -f frontend-deployment.yaml -n appsmith
kubectl apply -f backend-deployment.yaml -n appsmith

# Aplicar Services
kubectl apply -f frontend-service.yaml -n appsmith
kubectl apply -f backend-service.yaml -n appsmith

# Aplicar Ingress
kubectl apply -f ingress.yaml -n appsmith
```

### 3. Verificar Status

```bash
# Ver pods
kubectl get pods -n appsmith

# Ver logs do frontend
kubectl logs -f deployment/appsmith-frontend -n appsmith

# Ver logs do backend
kubectl logs -f deployment/appsmith-backend -n appsmith

# Testar conectividade
kubectl exec -it deployment/appsmith-frontend -n appsmith -- curl http://appsmith-backend:8080/api/v1/health
```

---

## ✅ Checklist de Deploy

- [ ] Build do frontend com variáveis de ambiente (se necessário)
- [ ] ConfigMap do Nginx criado
- [ ] Deployment do frontend criado
- [ ] Deployment do backend criado
- [ ] Services criados
- [ ] Ingress configurado com TLS
- [ ] Variáveis de ambiente do backend configuradas
- [ ] `APPSMITH_CUSTOM_DOMAIN` configurado no backend
- [ ] MongoDB e Redis acessíveis pelo backend
- [ ] Testar acesso ao frontend
- [ ] Testar chamadas de API do frontend para o backend
- [ ] Verificar cookies e sessões
- [ ] Verificar CORS
- [ ] Verificar CSRF (testar login)

---

## 🐛 Troubleshooting

### Frontend não consegue acessar o backend

1. Verificar se o Service do backend está correto:
   ```bash
   kubectl get svc appsmith-backend -n appsmith
   ```

2. Testar conectividade do frontend para o backend:
   ```bash
   kubectl exec -it deployment/appsmith-frontend -n appsmith -- \
     curl http://appsmith-backend:8080/api/v1/health
   ```

3. Verificar logs do Nginx:
   ```bash
   kubectl logs -f deployment/appsmith-frontend -n appsmith
   ```

### Erro 403 Forbidden (CSRF)

1. Verificar se os headers estão sendo passados:
   ```bash
   kubectl logs -f deployment/appsmith-backend -n appsmith | grep CSRF
   ```

2. Verificar configuração do Nginx (deve passar `X-Appsmith-Version` e `X-Requested-By`)

### Cookies não funcionam

1. Verificar `APPSMITH_CUSTOM_DOMAIN` no backend
2. Verificar configuração de cookies no Nginx
3. Verificar se está usando HTTPS (cookies `Secure` requerem HTTPS)

---

## 📚 Referências

- [Appsmith Documentation](https://docs.appsmith.com/)
- [Kubernetes Ingress](https://kubernetes.io/docs/concepts/services-networking/ingress/)
- [Nginx Proxy](https://nginx.org/en/docs/http/ngx_http_proxy_module.html)

