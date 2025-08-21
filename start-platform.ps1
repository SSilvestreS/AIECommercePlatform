# AIECommerce Platform Startup Script
Write-Host "Starting AIECommerce Platform..." -ForegroundColor Green

# Check Docker
Write-Host "Checking Docker..." -ForegroundColor Yellow
docker version | Out-Null
Write-Host "Docker is running" -ForegroundColor Green

# Stop existing containers
Write-Host "Stopping existing containers..." -ForegroundColor Yellow
docker-compose down 2>$null
docker-compose -f docker-compose.services.yml down 2>$null

# Start infrastructure
Write-Host "Starting infrastructure..." -ForegroundColor Yellow
docker-compose up -d postgres redis rabbitmq mlflow minio prometheus grafana jaeger elasticsearch logstash kibana

# Wait for infrastructure
Write-Host "Waiting for infrastructure..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Check status
Write-Host "Checking infrastructure status..." -ForegroundColor Yellow
docker-compose ps

# Start application services
Write-Host "Starting application services..." -ForegroundColor Yellow
docker-compose -f docker-compose.services.yml up -d

# Wait for services
Write-Host "Waiting for services..." -ForegroundColor Yellow
Start-Sleep -Seconds 20

# Final status
Write-Host "Final service status:" -ForegroundColor Yellow
docker-compose -f docker-compose.services.yml ps

Write-Host "Platform started successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "Service URLs:" -ForegroundColor Cyan
Write-Host "  Gateway API: http://localhost:5000" -ForegroundColor White
Write-Host "  Gateway Swagger: http://localhost:5000/swagger" -ForegroundColor White
Write-Host "  ML Recommendation: http://localhost:5001" -ForegroundColor White
Write-Host "  ML Recommendation Swagger: http://localhost:5001/swagger" -ForegroundColor White
Write-Host ""
Write-Host "Monitoring Tools:" -ForegroundColor Cyan
Write-Host "  Grafana: http://localhost:3000 (admin/admin123)" -ForegroundColor White
Write-Host "  Prometheus: http://localhost:9090" -ForegroundColor White
Write-Host "  Jaeger: http://localhost:16686" -ForegroundColor White
Write-Host "  Kibana: http://localhost:5601" -ForegroundColor White
Write-Host "  MLflow: http://localhost:5000" -ForegroundColor White
Write-Host "  MinIO: http://localhost:9001 (minioadmin/minioadmin123)" -ForegroundColor White
Write-Host ""
Write-Host "Use Postman to test the APIs!" -ForegroundColor Yellow
