# 🚀 AIECommerce Platform - Guia de Início Rápido

## 📋 Pré-requisitos

- **Docker Desktop** instalado e rodando
- **.NET 8.0 SDK** instalado
- **Git** instalado
- **PostgreSQL 15+** (opcional, pode usar Docker)
- **Redis 7+** (opcional, pode usar Docker)

## 🏃‍♂️ Execução Rápida

### 1. Clone o Repositório
```bash
git clone <your-repo-url>
cd AIECommercePlatform
```

### 2. Execute com Docker Compose
```bash
# Inicie todos os serviços
docker-compose up -d

# Verifique o status
docker-compose ps

# Veja os logs
docker-compose logs -f
```

### 3. Acesse as Interfaces

- **API Gateway**: http://localhost:5000
- **Grafana**: http://localhost:3000 (admin/admin123)
- **Prometheus**: http://localhost:9090
- **Jaeger**: http://localhost:16686
- **Kibana**: http://localhost:5601
- **MLflow**: http://localhost:5000
- **MinIO Console**: http://localhost:9001 (minioadmin/minioadmin123)

## 🧪 Testando os Serviços

### Teste de Recomendações
```bash
curl -X POST http://localhost:5000/recommendations \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "123e4567-e89b-12d3-a456-426614174000",
    "maxRecommendations": 5
  }'
```

### Teste de Análise de Sentimentos
```bash
curl -X POST http://localhost:5000/sentiment \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Este produto é incrível! Recomendo muito!"
  }'
```

### Teste de Detecção de Fraude
```bash
curl -X POST http://localhost:5000/fraud \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "123e4567-e89b-12d3-a456-426614174000",
    "orderAmount": 1500.00,
    "paymentMethod": "credit_card",
    "ipAddress": "192.168.1.1"
  }'
```

## 🐳 Desenvolvimento Local

### 1. Execute Apenas os Serviços de Infraestrutura
```bash
docker-compose up -d postgres redis rabbitmq
```

### 2. Execute os Serviços .NET Individualmente
```bash
# Terminal 1 - API Gateway
dotnet run --project src/Gateway/AIECommerce.Gateway

# Terminal 2 - ML Recommendation Service
dotnet run --project src/ML.Services/AIECommerce.ML.RecommendationService

# Terminal 3 - ML Sentiment Service
dotnet run --project src/ML.Services/AIECommerce.ML.SentimentAnalysisService

# Terminal 4 - ML Fraud Service
dotnet run --project src/ML.Services/AIECommerce.ML.FraudDetectionService

# Terminal 5 - ML Demand Service
dotnet run --project src/ML.Services/AIECommerce.ML.DemandForecastingService
```

## ☸️ Kubernetes

### 1. Aplique o Namespace
```bash
kubectl apply -f k8s/namespace.yaml
```

### 2. Aplique os Serviços
```bash
kubectl apply -f k8s/
```

### 3. Verifique o Status
```bash
kubectl get pods -n aiecommerce
kubectl get services -n aiecommerce
kubectl get ingress -n aiecommerce
```

### 4. Acesse via Ingress
```bash
# Adicione ao /etc/hosts
127.0.0.1 api.aiecommerce.com
127.0.0.1 ml.aiecommerce.com
127.0.0.1 dashboard.aiecommerce.com
```

## 🎯 Helm Charts

### 1. Adicione os Repositórios
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add elastic https://helm.elastic.co
helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
helm repo update
```

### 2. Instale a Plataforma
```bash
helm install aiecommerce ./helm/aiecommerce \
  --namespace aiecommerce \
  --create-namespace
```

### 3. Atualize a Configuração
```bash
helm upgrade aiecommerce ./helm/aiecommerce \
  --namespace aiecommerce \
  --set global.environment=production
```

## 🔧 Configuração

### Variáveis de Ambiente
```bash
# PostgreSQL
POSTGRES_CONNECTION_STRING=Host=localhost;Database=aiecommerce;Username=postgres;Password=password123

# Redis
REDIS_CONNECTION_STRING=localhost:6379

# RabbitMQ
RABBITMQ_CONNECTION_STRING=amqp://guest:guest@localhost:5672/

# MLflow
MLFLOW_TRACKING_URI=http://localhost:5000

# MinIO
MINIO_ENDPOINT=http://localhost:9000
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=minioadmin123
```

### Configuração do Banco
```bash
# Conecte ao PostgreSQL
docker exec -it aiecommerce-postgres psql -U postgres -d aiecommerce

# Verifique as tabelas
\dt

# Verifique os dados de exemplo
SELECT * FROM users LIMIT 5;
SELECT * FROM products LIMIT 5;
```

## 📊 Monitoramento

### 1. Grafana Dashboards
- Acesse http://localhost:3000
- Login: admin/admin123
- Importe os dashboards do diretório `docker/grafana/provisioning/dashboards/`

### 2. Prometheus Queries
```promql
# Taxa de requisições por serviço
rate(http_requests_total{job=~"aiecommerce-.*"}[5m])

# Uso de memória por pod
container_memory_usage_bytes{namespace="aiecommerce"}

# Latência dos serviços ML
histogram_quantile(0.95, rate(ml_prediction_duration_seconds_bucket[5m]))
```

### 3. Jaeger Traces
- Acesse http://localhost:16686
- Procure por traces dos serviços ML
- Analise a latência de cada operação

## 🧪 Testes

### Testes Unitários
```bash
dotnet test tests/AIECommerce.Tests.Unit/
```

### Testes de Integração
```bash
dotnet test tests/AIECommerce.Tests.Integration/
```

### Testes de Performance
```bash
# Instale o Artillery
npm install -g artillery

# Execute os testes
artillery run performance-tests/load-test.yml
```

## 🚀 Deploy em Produção

### 1. Build das Imagens
```bash
# Build de todos os serviços
docker build -f docker/Dockerfile.Gateway -t aiecommerce/api-gateway:latest .
docker build -f docker/Dockerfile.RecommendationService -t aiecommerce/ml-recommendation:latest .
docker build -f docker/Dockerfile.SentimentService -t aiecommerce/ml-sentiment:latest .
docker build -f docker/Dockerfile.FraudService -t aiecommerce/ml-fraud:latest .
docker build -f docker/Dockerfile.DemandService -t aiecommerce/ml-demand:latest .
```

### 2. Push para Registry
```bash
# Faça login no registry
docker login your-registry.com

# Push das imagens
docker push aiecommerce/api-gateway:latest
docker push aiecommerce/ml-recommendation:latest
docker push aiecommerce/ml-sentiment:latest
docker push aiecommerce/ml-fraud:latest
docker push aiecommerce/ml-demand:latest
```

### 3. Deploy no Kubernetes
```bash
# Atualize as tags das imagens no values.yaml
helm upgrade aiecommerce ./helm/aiecommerce \
  --namespace aiecommerce \
  --set mlServices.recommendation.image.tag=latest \
  --set mlServices.sentiment.image.tag=latest \
  --set mlServices.fraud.image.tag=latest \
  --set mlServices.demand.image.tag=latest
```

## 🆘 Troubleshooting

### Problemas Comuns

#### 1. Serviços não iniciam
```bash
# Verifique os logs
docker-compose logs [service-name]

# Verifique o status dos containers
docker-compose ps

# Reinicie os serviços
docker-compose restart [service-name]
```

#### 2. Problemas de Conexão com Banco
```bash
# Verifique se o PostgreSQL está rodando
docker exec -it aiecommerce-postgres pg_isready

# Teste a conexão
docker exec -it aiecommerce-postgres psql -U postgres -d aiecommerce -c "SELECT 1;"
```

#### 3. Problemas de ML
```bash
# Verifique se os modelos estão carregados
curl http://localhost:5000/health

# Verifique os logs do MLflow
docker-compose logs mlflow

# Verifique o MinIO
curl http://localhost:9000/minio/health/live
```

### Logs Úteis
```bash
# Todos os logs
docker-compose logs -f

# Logs de um serviço específico
docker-compose logs -f ml-recommendation

# Logs das últimas 100 linhas
docker-compose logs --tail=100 [service-name]
```

## 📚 Próximos Passos

1. **Personalize os Modelos ML**: Ajuste os algoritmos para seu domínio
2. **Configure Alertas**: Configure notificações para métricas importantes
3. **Implemente A/B Testing**: Compare diferentes versões dos modelos ML
4. **Adicione Novos Serviços**: Expanda a plataforma com novos microserviços
5. **Configure Backup**: Implemente backup automático dos dados e modelos
6. **Implemente CI/CD**: Configure o pipeline de deploy automático

## 🤝 Suporte

- 📧 **Email**: support@aiecommerce.com
- 💬 **Discord**: [AIECommerce Community](https://discord.gg/aiecommerce)
- 📖 **Documentação**: [docs.aiecommerce.com](https://docs.aiecommerce.com)
- 🐛 **Issues**: [GitHub Issues](https://github.com/yourusername/aiecommerce-platform/issues)

---

**🎉 Parabéns! Você está executando uma plataforma de IA de nível empresarial!**
