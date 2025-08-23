#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Script de Setup para CI/CD - AIECommerce Platform
    
.DESCRIPTION
    Este script configura o ambiente para CI/CD incluindo:
    - Verificação de pré-requisitos
    - Configuração de secrets
    - Setup de ferramentas
    - Validação de configurações
    
.EXAMPLE
    .\setup-cicd.ps1
#>

# Configurações
$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

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
    
    $prerequisites = @{
        "Git" = $false
        "Docker" = $false
        "kubectl" = $false
        "Helm" = $false
        "PowerShell" = $false
    }
    
    # Verificar Git
    try {
        $gitVersion = git --version
        if ($gitVersion) {
            Write-ColorOutput "   ✅ Git: $gitVersion" $Colors.Success
            $prerequisites["Git"] = $true
        }
    }
    catch {
        Write-ColorOutput "   ❌ Git não encontrado" $Colors.Error
    }
    
    # Verificar Docker
    try {
        $dockerVersion = docker --version
        if ($dockerVersion) {
            Write-ColorOutput "   ✅ Docker: $dockerVersion" $Colors.Success
            $prerequisites["Docker"] = $true
        }
    }
    catch {
        Write-ColorOutput "   ❌ Docker não encontrado" $Colors.Error
    }
    
    # Verificar kubectl
    try {
        $kubectlVersion = kubectl version --client --output=json | ConvertFrom-Json
        if ($kubectlVersion) {
            Write-ColorOutput "   ✅ kubectl: $($kubectlVersion.clientVersion.gitVersion)" $Colors.Success
            $prerequisites["kubectl"] = $true
        }
    }
    catch {
        Write-ColorOutput "   ❌ kubectl não encontrado" $Colors.Error
    }
    
    # Verificar Helm
    try {
        $helmVersion = helm version --short
        if ($helmVersion) {
            Write-ColorOutput "   ✅ Helm: $helmVersion" $Colors.Success
            $prerequisites["Helm"] = $true
        }
    }
    catch {
        Write-ColorOutput "   ❌ Helm não encontrado" $Colors.Error
    }
    
    # Verificar PowerShell
    try {
        $psVersion = $PSVersionTable.PSVersion
        if ($psVersion) {
            Write-ColorOutput "   ✅ PowerShell: $psVersion" $Colors.Success
            $prerequisites["PowerShell"] = $true
        }
    }
    catch {
        Write-ColorOutput "   ❌ PowerShell não encontrado" $Colors.Error
    }
    
    # Resumo dos pré-requisitos
    $allMet = $prerequisites.Values -notcontains $false
    if ($allMet) {
        Write-ColorOutput "✅ Todos os pré-requisitos estão atendidos!" $Colors.Success
        return $true
    } else {
        Write-ColorOutput "❌ Alguns pré-requisitos não estão atendidos:" $Colors.Error
        foreach ($prereq in $prerequisites.GetEnumerator()) {
            if (-not $prereq.Value) {
                Write-ColorOutput "   - $($prereq.Key)" $Colors.Error
            }
        }
        return $false
    }
}

# Função para configurar secrets do GitHub
function Setup-GitHubSecrets {
    Write-ColorOutput "🔐 Configurando GitHub Secrets..." $Colors.Info
    
    $secrets = @{
        "SONAR_TOKEN" = "Token do SonarCloud para análise de qualidade"
        "SONAR_PROJECT_KEY" = "Chave do projeto no SonarCloud"
        "SONAR_ORGANIZATION" = "Organização no SonarCloud"
        "SNYK_TOKEN" = "Token do Snyk para scan de segurança"
        "KUBE_CONFIG_STAGING" = "Configuração base64 do Kubernetes para staging"
        "KUBE_CONFIG_PRODUCTION" = "Configuração base64 do Kubernetes para produção"
    }
    
    Write-ColorOutput "   Os seguintes secrets são necessários no GitHub:" $Colors.Info
    foreach ($secret in $secrets.GetEnumerator()) {
        Write-ColorOutput "   - $($secret.Key): $($secret.Value)" $Colors.Info
    }
    
    Write-ColorOutput "   Para configurar:" $Colors.Info
    Write-ColorOutput "   1. Vá para Settings > Secrets and variables > Actions" $Colors.Info
    Write-ColorOutput "   2. Clique em 'New repository secret'" $Colors.Info
    Write-ColorOutput "   3. Adicione cada secret com o valor correspondente" $Colors.Info
    
    $configured = Read-Host "   Todos os secrets estão configurados? (y/N)"
    if ($configured -eq "y" -or $configured -eq "Y") {
        Write-ColorOutput "   ✅ Secrets configurados!" $Colors.Success
        return $true
    } else {
        Write-ColorOutput "   ⚠️ Configure os secrets antes de continuar" $Colors.Warning
        return $false
    }
}

# Função para configurar SonarCloud
function Setup-SonarCloud {
    Write-ColorOutput "🔍 Configurando SonarCloud..." $Colors.Info
    
    Write-ColorOutput "   Para configurar o SonarCloud:" $Colors.Info
    Write-ColorOutput "   1. Acesse https://sonarcloud.io" $Colors.Info
    Write-ColorOutput "   2. Crie uma nova organização ou use uma existente" $Colors.Info
    Write-ColorOutput "   3. Crie um novo projeto para o repositório" $Colors.Info
    Write-ColorOutput "   4. Gere um token de acesso" $Colors.Info
    Write-ColorOutput "   5. Configure o arquivo sonar-project.properties" $Colors.Info
    
    # Verificar se o arquivo sonar-project.properties existe
    if (Test-Path "sonar-project.properties") {
        Write-ColorOutput "   ✅ Arquivo sonar-project.properties encontrado" $Colors.Success
    } else {
        Write-ColorOutput "   ❌ Arquivo sonar-project.properties não encontrado" $Colors.Error
        Write-ColorOutput "   Crie o arquivo baseado no template fornecido" $Colors.Info
    }
    
    $configured = Read-Host "   SonarCloud está configurado? (y/N)"
    if ($configured -eq "y" -or $configured -eq "Y") {
        Write-ColorOutput "   ✅ SonarCloud configurado!" $Colors.Success
        return $true
    } else {
        Write-ColorOutput "   ⚠️ Configure o SonarCloud antes de continuar" $Colors.Warning
        return $false
    }
}

# Função para configurar Kubernetes
function Setup-Kubernetes {
    Write-ColorOutput "☸️ Configurando Kubernetes..." $Colors.Info
    
    try {
        # Verificar conexão com cluster
        $clusterInfo = kubectl cluster-info
        Write-ColorOutput "   ✅ Conectado ao cluster Kubernetes" $Colors.Success
        
        # Verificar namespace
        $namespaceExists = kubectl get namespace aiecommerce --ignore-not-found
        if (-not $namespaceExists) {
            Write-ColorOutput "   ⚠️ Namespace 'aiecommerce' não existe" $Colors.Warning
            $createNamespace = Read-Host "   Criar namespace 'aiecommerce'? (Y/n)"
            if ($createNamespace -ne "n" -and $createNamespace -ne "N") {
                kubectl create namespace aiecommerce
                Write-ColorOutput "   ✅ Namespace 'aiecommerce' criado" $Colors.Success
            }
        } else {
            Write-ColorOutput "   ✅ Namespace 'aiecommerce' existe" $Colors.Success
        }
        
        # Verificar storage class
        $storageClasses = kubectl get storageclass
        Write-ColorOutput "   Storage Classes disponíveis:" $Colors.Info
        Write-Output $storageClasses
        
        return $true
    }
    catch {
        Write-ColorOutput "   ❌ Erro ao configurar Kubernetes: $($_.Exception.Message)" $Colors.Error
        return $false
    }
}

# Função para configurar Docker Registry
function Setup-DockerRegistry {
    Write-ColorOutput "🐳 Configurando Docker Registry..." $Colors.Info
    
    Write-ColorOutput "   Para configurar o Docker Registry:" $Colors.Info
    Write-ColorOutput "   1. Crie um Container Registry (GitHub Container Registry, Azure, AWS, etc.)" $Colors.Info
    Write-ColorOutput "   2. Configure as permissões de acesso" $Colors.Info
    Write-ColorOutput "   3. Atualize o workflow do GitHub Actions" $Colors.Info
    
    # Verificar se o workflow existe
    if (Test-Path ".github/workflows/ci-cd-pipeline.yml") {
        Write-ColorOutput "   ✅ Workflow CI/CD encontrado" $Colors.Success
    } else {
        Write-ColorOutput "   ❌ Workflow CI/CD não encontrado" $Colors.Error
    }
    
    $configured = Read-Host "   Docker Registry está configurado? (y/N)"
    if ($configured -eq "y" -or $configured -eq "Y") {
        Write-ColorOutput "   ✅ Docker Registry configurado!" $Colors.Success
        return $true
    } else {
        Write-ColorOutput "   ⚠️ Configure o Docker Registry antes de continuar" $Colors.Warning
        return $false
    }
}

# Função para validar configurações
function Test-Configurations {
    Write-ColorOutput "✅ Validando configurações..." $Colors.Info
    
    $configs = @{
        "GitHub Secrets" = $false
        "SonarCloud" = $false
        "Kubernetes" = $false
        "Docker Registry" = $false
    }
    
    # Validar GitHub Secrets
    $configs["GitHub Secrets"] = Setup-GitHubSecrets
    
    # Validar SonarCloud
    $configs["SonarCloud"] = Setup-SonarCloud
    
    # Validar Kubernetes
    $configs["Kubernetes"] = Setup-Kubernetes
    
    # Validar Docker Registry
    $configs["Docker Registry"] = Setup-DockerRegistry
    
    # Resumo das configurações
    Write-ColorOutput "   Resumo das configurações:" $Colors.Info
    foreach ($config in $configs.GetEnumerator()) {
        $status = if ($config.Value) { "✅" } else { "❌" }
        Write-ColorOutput "   $status $($config.Key)" $Colors.Info
    }
    
    $allConfigured = $configs.Values -notcontains $false
    if ($allConfigured) {
        Write-ColorOutput "🎉 Todas as configurações estão prontas!" $Colors.Success
        return $true
    } else {
        Write-ColorOutput "⚠️ Algumas configurações precisam ser completadas" $Colors.Warning
        return $false
    }
}

# Função para executar testes de validação
function Test-Validation {
    Write-ColorOutput "🧪 Executando testes de validação..." $Colors.Info
    
    try {
        # Testar build do projeto
        Write-ColorOutput "   Testando build do projeto..." $Colors.Info
        dotnet build --configuration Release
        
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "   ✅ Build bem-sucedido" $Colors.Success
        } else {
            Write-ColorOutput "   ❌ Build falhou" $Colors.Error
            return $false
        }
        
        # Testar testes unitários
        Write-ColorOutput "   Testando testes unitários..." $Colors.Info
        dotnet test --configuration Release --no-build
        
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "   ✅ Testes unitários passaram" $Colors.Success
        } else {
            Write-ColorOutput "   ❌ Testes unitários falharam" $Colors.Error
            return $false
        }
        
        # Testar build Docker
        Write-ColorOutput "   Testando build Docker..." $Colors.Info
        docker build -t aiecommerce-gateway:test ./src/Gateway/AIECommerce.Gateway
        
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "   ✅ Build Docker bem-sucedido" $Colors.Success
        } else {
            Write-ColorOutput "   ❌ Build Docker falhou" $Colors.Error
            return $false
        }
        
        Write-ColorOutput "✅ Todos os testes de validação passaram!" $Colors.Success
        return $true
    }
    catch {
        Write-ColorOutput "❌ Erro durante testes de validação: $($_.Exception.Message)" $Colors.Error
        return $false
    }
}

# Função para mostrar próximos passos
function Show-NextSteps {
    Write-ColorOutput "🚀 Próximos passos para CI/CD:" $Colors.Info
    Write-ColorOutput "   1. Configure os secrets no GitHub" $Colors.Info
    Write-ColorOutput "   2. Configure o SonarCloud" $Colors.Info
    Write-ColorOutput "   3. Configure o Kubernetes" $Colors.Info
    Write-ColorOutput "   4. Configure o Docker Registry" $Colors.Info
    Write-ColorOutput "   5. Faça push para a branch main/develop" $Colors.Info
    Write-ColorOutput "   6. Monitore o pipeline no GitHub Actions" $Colors.Info
    Write-ColorOutput "   7. Execute o deploy para staging" $Colors.Info
    Write-ColorOutput "   8. Execute testes de performance" $Colors.Info
    Write-ColorOutput "   9. Execute o deploy para produção" $Colors.Info
    
    Write-ColorOutput "   📚 Documentação disponível em:" $Colors.Info
    Write-ColorOutput "   - docs/DEPLOYMENT.md" $Colors.Info
    Write-ColorOutput "   - .github/workflows/ci-cd-pipeline.yml" $Colors.Info
    Write-ColorOutput "   - scripts/deploy-production.ps1" $Colors.Info
}

# Função principal
function Main {
    Write-ColorOutput "🚀 AIECommerce Platform - Setup CI/CD" $Colors.Info
    Write-ColorOutput "=====================================" $Colors.Info
    
    try {
        # 1. Verificar pré-requisitos
        $prereqsMet = Test-Prerequisites
        if (-not $prereqsMet) {
            Write-ColorOutput "❌ Pré-requisitos não atendidos. Configure-os antes de continuar." $Colors.Error
            exit 1
        }
        
        # 2. Validar configurações
        $configsValid = Test-Configurations
        if (-not $configsValid) {
            Write-ColorOutput "⚠️ Algumas configurações precisam ser completadas." $Colors.Warning
        }
        
        # 3. Executar testes de validação
        $validationPassed = Test-Validation
        if (-not $validationPassed) {
            Write-ColorOutput "❌ Testes de validação falharam. Corrija os problemas antes de continuar." $Colors.Error
        }
        
        # 4. Mostrar próximos passos
        Show-NextSteps
        
        if ($configsValid -and $validationPassed) {
            Write-ColorOutput "🎉 Setup CI/CD concluído com sucesso!" $Colors.Success
            Write-ColorOutput "   Você está pronto para executar o pipeline CI/CD!" $Colors.Success
        } else {
            Write-ColorOutput "⚠️ Setup CI/CD concluído com algumas pendências." $Colors.Warning
            Write-ColorOutput "   Complete as configurações pendentes antes de executar o pipeline." $Colors.Warning
        }
    }
    catch {
        Write-ColorOutput "❌ Erro durante setup CI/CD: $($_.Exception.Message)" $Colors.Error
        exit 1
    }
}

# Executar função principal
Main
