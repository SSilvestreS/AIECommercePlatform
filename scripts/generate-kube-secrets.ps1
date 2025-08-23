#!/usr/bin/env pwsh

<#
.SYNOPSIS
    Script para gerar secrets do Kubernetes em base64 para GitHub Actions
.DESCRIPTION
    Este script ajuda a converter arquivos kubeconfig para o formato base64 necessário para os secrets do GitHub
#>

param(
    [Parameter(Mandatory = $false)]
    [string]$KubeconfigPath = "$HOME\.kube\config"
)

# Cores para output
$Colors = @{
    Success = "Green"
    Warning = "Yellow"
    Error = "Red"
    Info = "Cyan"
}

function Write-ColorOutput {
    param([string]$Message, [string]$Color)
    Write-Host $Message -ForegroundColor $Color
}

function Convert-KubeconfigToBase64 {
    param([string]$ConfigPath)
    
    if (-not (Test-Path $ConfigPath)) {
        Write-ColorOutput "❌ Arquivo kubeconfig não encontrado: $ConfigPath" $Colors.Error
        return $null
    }
    
    try {
        $configContent = Get-Content $ConfigPath -Raw
        $base64Content = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($configContent))
        return $base64Content
    }
    catch {
        Write-ColorOutput "❌ Erro ao converter kubeconfig: $($_.Exception.Message)" $Colors.Error
        return $null
    }
}

function Main {
    Write-ColorOutput "🔐 Gerador de Secrets Kubernetes para GitHub Actions" $Colors.Info
    Write-ColorOutput "=================================================" $Colors.Info
    
    # Verificar se kubeconfig existe
    if (-not (Test-Path $KubeconfigPath)) {
        Write-ColorOutput "❌ Kubeconfig não encontrado em: $KubeconfigPath" $Colors.Error
        Write-ColorOutput "💡 Especifique o caminho: .\generate-kube-secrets.ps1 -KubeconfigPath 'C:\path\to\kubeconfig'" $Colors.Warning
        return
    }
    
    Write-ColorOutput "📁 Usando kubeconfig: $KubeconfigPath" $Colors.Info
    
    # Converter para base64
    $base64Config = Convert-KubeconfigToBase64 -ConfigPath $KubeconfigPath
    
    if ($null -eq $base64Config) {
        Write-ColorOutput "❌ Falha ao gerar base64" $Colors.Error
        return
    }
    
    Write-ColorOutput "✅ Kubeconfig convertido com sucesso!" $Colors.Success
    Write-ColorOutput "" $Colors.Info
    Write-ColorOutput "📋 Copie o valor abaixo para o GitHub Secret:" $Colors.Warning
    Write-ColorOutput "=================================================" $Colors.Info
    Write-Output $base64Config
    Write-ColorOutput "=================================================" $Colors.Info
    Write-ColorOutput "" $Colors.Info
    Write-ColorOutput "🔧 Como usar:" $Colors.Info
    Write-ColorOutput "1. Copie o valor acima" $Colors.Info
    Write-ColorOutput "2. Vá para GitHub → Settings → Secrets and variables → Actions" $Colors.Info
    Write-ColorOutput "3. Clique 'New repository secret'" $Colors.Info
    Write-ColorOutput "4. Nome: KUBE_CONFIG_STAGING ou KUBE_CONFIG_PRODUCTION" $Colors.Info
    Write-ColorOutput "5. Cole o valor e salve" $Colors.Info
}

Main
