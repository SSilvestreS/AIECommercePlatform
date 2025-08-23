# 🔐 GitHub Secrets Configuration - AIECommerce Platform

Este documento lista todos os secrets necessários para o funcionamento completo do pipeline CI/CD.

## 📋 Secrets Obrigatórios

### SonarCloud Configuration
Configure estes secrets para análise de qualidade de código:

| Secret Name | Description | Example/Format |
|-------------|-------------|----------------|
| `SONAR_TOKEN` | Token de autenticação do SonarCloud | `sqp_1234567890abcdef...` |
| `SONAR_PROJECT_KEY` | Chave do projeto no SonarCloud | `aiecommerce-platform` |
| `SONAR_ORGANIZATION` | Organização no SonarCloud | `aiecommerce` |
| `SONAR_HOST_URL` | URL do SonarCloud | `https://sonarcloud.io` |

### Security Scanning
Configure este secret para análise de segurança:

| Secret Name | Description | Example/Format |
|-------------|-------------|----------------|
| `SNYK_TOKEN` | Token de autenticação do Snyk | `1234567890abcdef...` |

### Kubernetes Deployment
Configure estes secrets para deploy em Kubernetes:

| Secret Name | Description | Example/Format |
|-------------|-------------|----------------|
| `KUBE_CONFIG_STAGING` | Kubeconfig para cluster de staging (base64) | `YXBpVmVyc2lvbjogdjEKY2x1c3Rlcn...` |
| `KUBE_CONFIG_PRODUCTION` | Kubeconfig para cluster de produção (base64) | `YXBpVmVyc2lvbjogdjEKY2x1c3Rlcn...` |

## 🛠️ Como Configurar os Secrets

### 1. Acessar GitHub Repository Settings
1. Vá para o repositório no GitHub
2. Clique em **Settings**
3. No menu lateral, clique em **Secrets and variables** → **Actions**

### 2. Adicionar Secrets
1. Clique em **New repository secret**
2. Digite o nome do secret (ex: `SONAR_TOKEN`)
3. Cole o valor do secret
4. Clique em **Add secret**

### 3. Obter Tokens e Configurações

#### SonarCloud
1. Acesse [SonarCloud](https://sonarcloud.io)
2. Faça login e crie um projeto
3. Vá em **My Account** → **Security** → **Generate Tokens**
4. Copie os valores necessários

#### Snyk
1. Acesse [Snyk](https://app.snyk.io)
2. Faça login e vá em **Settings** → **General** → **Auth Token**
3. Copie o token

#### Kubernetes
1. Para staging e produção, obtenha o arquivo kubeconfig
2. Codifique em base64: `cat kubeconfig.yaml | base64 -w 0`
3. Use o resultado como valor do secret

## ⚠️ Importante

- **Nunca** commite secrets no código
- Os secrets são específicos do ambiente (staging/production)
- Mantenha os tokens atualizados
- Use princípio do menor privilégio para os tokens

## 🔍 Verificação

Para verificar se os secrets estão configurados corretamente:

1. Execute o workflow CI/CD
2. Verifique os logs para erros de autenticação
3. Use o script de setup: `.\scripts\setup-cicd.ps1`

## 📞 Suporte

Em caso de problemas com a configuração dos secrets:
- Verifique a documentação oficial de cada ferramenta
- Consulte os logs do workflow no GitHub Actions
- Entre em contato com a equipe de DevOps
