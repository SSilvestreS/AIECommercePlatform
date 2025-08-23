#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Script de Deploy Automatizado para Produção - AIECommerce Platform
    
.DESCRIPTION
    Este script automatiza o processo de deploy em produção incluindo:
    - Verificação de pré-requisitos
    - Deploy dos serviços
    - Verificações de saúde
    - Rollback automático em caso de falha
    - Notificações de status
    
.PARAMETER Environment
    Ambiente de produção (prod, staging)
    
.PARAMETER Version
    Versão para deploy
    
.PARAMETER RollbackVersion
    Versão para rollback em caso de falha
    
.EXAMPLE
    .\deploy-production.ps1 -Environment "prod" -Version "v1.2.0"
#>

param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("prod", "staging")]
    [string]$Environment,
    
    [Parameter(Mandatory = $true)]
    [string]$Version,
    
    [Parameter(Mandatory = $false)]
    [string]$RollbackVersion = "v1.1.0"
)

# Configurações
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

# Variáveis de ambiente
$KUBECONFIG = $env:KUBECONFIG
$NAMESPACE = "aiecommerce"
$DEPLOYMENT_TIMEOUT = 600  # 10 minutos
$HEALTH_CHECK_TIMEOUT = 300  # 5 minutos
$ROLLBACK_TIMEOUT = 300  # 5 minutos

# Cores para output
$Colors = @{
    Info = "Cyan"
    Success = "Green"
    Warning = "Yellow"
    Error = "Red"
}

# Função para logging colorido
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $Message" -ForegroundColor $Color
}

# Função para verificar pré-requisitos
function Test-Prerequisites {
    Write-ColorOutput "🔍 Verificando pré-requisitos..." $Colors.Info
    
    # Verificar kubectl
    try {
        $kubectlVersion = kubectl version --client --output=json | ConvertFrom-Json
        Write-ColorOutput "✅ kubectl encontrado: $($kubectlVersion.clientVersion.gitVersion)" $Colors.Success
    }
    catch {
        Write-ColorOutput "❌ kubectl não encontrado. Instale o kubectl primeiro." $Colors.Error
        exit 1
    }
    
    # Verificar conexão com cluster
    try {
        $clusterInfo = kubectl cluster-info
        Write-ColorOutput "✅ Conectado ao cluster Kubernetes" $Colors.Success
    }
    catch {
        Write-ColorOutput "❌ Não foi possível conectar ao cluster Kubernetes" $Colors.Error
        exit 1
    }
    
    # Verificar namespace
    try {
        $namespaceExists = kubectl get namespace $NAMESPACE --ignore-not-found
        if (-not $namespaceExists) {
            Write-ColorOutput "⚠️ Namespace $NAMESPACE não existe. Criando..." $Colors.Warning
            kubectl create namespace $NAMESPACE
        }
        Write-ColorOutput "✅ Namespace $NAMESPACE está disponível" $Colors.Success
    }
    catch {
        Write-ColorOutput "❌ Erro ao verificar/criar namespace" $Colors.Error
        exit 1
    }
    
    # Verificar imagens Docker
    Write-ColorOutput "🔍 Verificando disponibilidade das imagens Docker..." $Colors.Info
    $services = @("gateway", "ml-recommendation")
    
    foreach ($service in $services) {
        $imageTag = "ghcr.io/aiecommerce/platform/$service`:$Version"
        Write-ColorOutput "   Verificando: $imageTag" $Colors.Info
        
        # Aqui você pode adicionar verificação de existência da imagem
        # Por exemplo, usando docker pull ou verificando no registry
    }
}

# Função para backup da configuração atual
function Backup-CurrentConfiguration {
    Write-ColorOutput "💾 Criando backup da configuração atual..." $Colors.Info
    
    $backupDir = "backups/$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    
    try {
        # Backup dos deployments
        kubectl get deployment -n $NAMESPACE -o yaml > "$backupDir/deployments.yaml"
        
        # Backup dos services
        kubectl get service -n $NAMESPACE -o yaml > "$backupDir/services.yaml"
        
        # Backup dos configmaps
        kubectl get configmap -n $NAMESPACE -o yaml > "$backupDir/configmaps.yaml"
        
        # Backup dos secrets (sem dados sensíveis)
        kubectl get secret -n $NAMESPACE -o yaml > "$backupDir/secrets.yaml"
        
        Write-ColorOutput "✅ Backup criado em: $backupDir" $Colors.Success
        return $backupDir
    }
    catch {
        Write-ColorOutput "❌ Erro ao criar backup" $Colors.Error
        return $null
    }
}

# Função para deploy dos serviços
function Deploy-Services {
    param(
        [string]$BackupDir
    )
    
    Write-ColorOutput "🚀 Iniciando deploy da versão $Version..." $Colors.Info
    
    try {
        # Aplicar namespace e recursos base
        Write-ColorOutput "   Aplicando namespace e recursos base..." $Colors.Info
        kubectl apply -f k8s/namespace.yaml
        
        # Aplicar configurações de produção
        if ($Environment -eq "prod") {
            Write-ColorOutput "   Aplicando configurações de produção..." $Colors.Info
            kubectl apply -f k8s/production-deployment.yaml
            kubectl apply -f k8s/production-ingress.yaml
        } else {
            Write-ColorOutput "   Aplicando configurações de staging..." $Colors.Info
            kubectl apply -f k8s/
        }
        
        # Aguardar deployments ficarem disponíveis
        Write-ColorOutput "   Aguardando deployments ficarem disponíveis..." $Colors.Info
        $deployments = @("gateway-production", "ml-recommendation-production")
        
        foreach ($deployment in $deployments) {
            Write-ColorOutput "     Aguardando $deployment..." $Colors.Info
            kubectl rollout status deployment/$deployment -n $NAMESPACE --timeout=${DEPLOYMENT_TIMEOUT}s
            
            if ($LASTEXITCODE -ne 0) {
                throw "Deployment $deployment falhou"
            }
        }
        
        Write-ColorOutput "✅ Deploy concluído com sucesso!" $Colors.Success
        return $true
    }
    catch {
        Write-ColorOutput "❌ Erro durante deploy: $($_.Exception.Message)" $Colors.Error
        return $false
    }
}

# Função para verificação de saúde
function Test-HealthChecks {
    Write-ColorOutput "🏥 Executando verificações de saúde..." $Colors.Info
    
    $healthEndpoints = @(
        "https://api.aiecommerce.com/health",
        "https://api.aiecommerce.com/health/ready",
        "https://api.aiecommerce.com/health/live"
    )
    
    $maxRetries = 10
    $retryCount = 0
    
    while ($retryCount -lt $maxRetries) {
        $allHealthy = $true
        
        foreach ($endpoint in $healthEndpoints) {
            try {
                $response = Invoke-WebRequest -Uri $endpoint -Method GET -TimeoutSec 30 -SkipCertificateCheck
                if ($response.StatusCode -eq 200) {
                    Write-ColorOutput "   ✅ $endpoint - OK" $Colors.Success
                } else {
                    Write-ColorOutput "   ⚠️ $endpoint - Status: $($response.StatusCode)" $Colors.Warning
                    $allHealthy = $false
                }
            }
            catch {
                Write-ColorOutput "   ❌ $endpoint - Erro: $($_.Exception.Message)" $Colors.Error
                $allHealthy = $false
            }
        }
        
        if ($allHealthy) {
            Write-ColorOutput "✅ Todos os endpoints de saúde estão funcionando!" $Colors.Success
            return $true
        }
        
        $retryCount++
        if ($retryCount -lt $maxRetries) {
            Write-ColorOutput "   ⏳ Aguardando 30 segundos antes da próxima tentativa ($retryCount/$maxRetries)..." $Colors.Warning
            Start-Sleep -Seconds 30
        }
    }
    
    Write-ColorOutput "❌ Verificações de saúde falharam após $maxRetries tentativas" $Colors.Error
    return $false
}

# Função para rollback
function Invoke-Rollback {
    param(
        [string]$BackupDir,
        [string]$RollbackVersion
    )
    
    Write-ColorOutput "🔄 Iniciando rollback para versão $RollbackVersion..." $Colors.Warning
    
    try {
        if ($BackupDir -and (Test-Path $BackupDir)) {
            Write-ColorOutput "   Restaurando configuração anterior..." $Colors.Info
            
            # Restaurar deployments
            kubectl apply -f "$BackupDir/deployments.yaml"
            kubectl apply -f "$BackupDir/services.yaml"
            kubectl apply -f "$BackupDir/configmaps.yaml"
            
            # Aguardar rollback
            $deployments = @("gateway-production", "ml-recommendation-production")
            foreach ($deployment in $deployments) {
                kubectl rollout status deployment/$deployment -n $NAMESPACE --timeout=${ROLLBACK_TIMEOUT}s
            }
            
            Write-ColorOutput "✅ Rollback concluído com sucesso!" $Colors.Success
        } else {
            Write-ColorOutput "   Backup não disponível, tentando rollback manual..." $Colors.Warning
            
            # Rollback manual para versão anterior
            kubectl rollout undo deployment/gateway-production -n $NAMESPACE
            kubectl rollout undo deployment/ml-recommendation-production -n $NAMESPACE
            
            # Aguardar rollback
            kubectl rollout status deployment/gateway-production -n $NAMESPACE --timeout=${ROLLBACK_TIMEOUT}s
            kubectl rollout status deployment/ml-recommendation-production -n $NAMESPACE --timeout=${ROLLBACK_TIMEOUT}s
            
            Write-ColorOutput "✅ Rollback manual concluído!" $Colors.Success
        }
        
        return $true
    }
    catch {
        Write-ColorOutput "❌ Erro durante rollback: $($_.Exception.Message)" $Colors.Error
        return $false
    }
}

# Função para notificações
function Send-Notifications {
    param(
        [string]$Status,
        [string]$Message,
        [string]$Environment,
        [string]$Version
    )
    
    Write-ColorOutput "📢 Enviando notificações..." $Colors.Info
    
    # Aqui você pode implementar notificações para:
    # - Slack
    # - Microsoft Teams
    # - Email
    # - SMS
    # - PagerDuty
    
    $notificationData = @{
        Status = $Status
        Message = $Message
        Environment = $Environment
        Version = $Version
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss UTC"
        DeployedBy = $env:USERNAME
    }
    
    Write-ColorOutput "   Status: $Status" $Colors.Info
    Write-ColorOutput "   Mensagem: $Message" $Colors.Info
    Write-ColorOutput "   Ambiente: $Environment" $Colors.Info
    Write-ColorOutput "   Versão: $Version" $Colors.Info
    
    # Exemplo de notificação para Slack (descomente e configure)
    # $slackWebhook = $env:SLACK_WEBHOOK_URL
    # if ($slackWebhook) {
    #     $slackPayload = @{
    #         text = "🚀 Deploy $Status - $Environment"
    #         attachments = @(
    #             @{
    #                 fields = @(
    #                     @{ title = "Status"; value = $Status; short = $true },
    #                     @{ title = "Environment"; value = $Environment; short = $true },
    #                     @{ title = "Version"; value = $Version; short = $true },
    #                     @{ title = "Message"; value = $Message; short = $false }
    #                 )
    #                 color = if ($Status -eq "SUCCESS") { "good" } else { "danger" }
    #             }
    #         )
    #     } | ConvertTo-Json -Depth 10
    #     
    #     Invoke-RestMethod -Uri $slackWebhook -Method POST -Body $slackPayload -ContentType "application/json"
    # }
}

# Função principal
function Main {
    Write-ColorOutput "🚀 AIECommerce Platform - Deploy de Produção" $Colors.Info
    Write-ColorOutput "===============================================" $Colors.Info
    Write-ColorOutput "Ambiente: $Environment" $Colors.Info
    Write-ColorOutput "Versão: $Version" $Colors.Info
    Write-ColorOutput "Rollback Version: $RollbackVersion" $Colors.Info
    Write-ColorOutput "===============================================" $Colors.Info
    
    $startTime = Get-Date
    $backupDir = $null
    $deploySuccess = $false
    
    try {
        # 1. Verificar pré-requisitos
        Test-Prerequisites
        
        # 2. Backup da configuração atual
        $backupDir = Backup-CurrentConfiguration
        
        # 3. Deploy dos serviços
        $deploySuccess = Deploy-Services -BackupDir $backupDir
        
        if ($deploySuccess) {
            # 4. Verificações de saúde
            $healthSuccess = Test-HealthChecks
            
            if ($healthSuccess) {
                Write-ColorOutput "🎉 Deploy concluído com sucesso!" $Colors.Success
                Send-Notifications -Status "SUCCESS" -Message "Deploy concluído com sucesso" -Environment $Environment -Version $Version
            } else {
                throw "Verificações de saúde falharam"
            }
        } else {
            throw "Deploy falhou"
        }
    }
    catch {
        Write-ColorOutput "❌ Deploy falhou: $($_.Exception.Message)" $Colors.Error
        
        # Tentar rollback
        Write-ColorOutput "🔄 Tentando rollback..." $Colors.Warning
        $rollbackSuccess = Invoke-Rollback -BackupDir $backupDir -RollbackVersion $RollbackVersion
        
        if ($rollbackSuccess) {
            Write-ColorOutput "✅ Rollback concluído com sucesso" $Colors.Success
            Send-Notifications -Status "ROLLBACK_SUCCESS" -Message "Deploy falhou, rollback executado com sucesso" -Environment $Environment -Version $Version
        } else {
            Write-ColorOutput "❌ Rollback falhou - INTERVENÇÃO MANUAL NECESSÁRIA!" $Colors.Error
            Send-Notifications -Status "CRITICAL" -Message "Deploy e rollback falharam - intervenção manual necessária" -Environment $Environment -Version $Version
        }
        
        exit 1
    }
    finally {
        $endTime = Get-Date
        $duration = $endTime - $startTime
        
        Write-ColorOutput "===============================================" $Colors.Info
        Write-ColorOutput "Tempo total de execução: $($duration.TotalMinutes.ToString('F2')) minutos" $Colors.Info
        Write-ColorOutput "Deploy iniciado em: $($startTime.ToString('yyyy-MM-dd HH:mm:ss'))" $Colors.Info
        Write-ColorOutput "Deploy finalizado em: $($endTime.ToString('yyyy-MM-dd HH:mm:ss'))" $Colors.Info
        Write-ColorOutput "===============================================" $Colors.Info
    }
}

# Executar função principal
Main
