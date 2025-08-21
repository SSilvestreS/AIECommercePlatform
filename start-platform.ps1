# Script para iniciar a plataforma AIECommerce
Write-Host "Starting AIECommerce Platform..." -ForegroundColor Green

# Iniciar infraestrutura
Write-Host "Starting infrastructure services..." -ForegroundColor Yellow
docker-compose up -d postgres redis rabbitmq prometheus grafana

# Aguardar infraestrutura
Start-Sleep -Seconds 10

# Iniciar serviços .NET
Write-Host "Starting .NET services..." -ForegroundColor Yellow
docker-compose up -d gateway ml-recommendation

# Aguardar serviços
Start-Sleep -Seconds 15

# Verificar status
Write-Host "Checking services status..." -ForegroundColor Yellow
docker ps

Write-Host "Platform started successfully!" -ForegroundColor Green
Write-Host "Gateway: http://localhost:5000" -ForegroundColor Cyan
Write-Host "ML Service: http://localhost:5002" -ForegroundColor Cyan
Write-Host "RabbitMQ: http://localhost:15672" -ForegroundColor Cyan
Write-Host "Grafana: http://localhost:3000" -ForegroundColor Cyan
Write-Host "Prometheus: http://localhost:9090" -ForegroundColor Cyan
