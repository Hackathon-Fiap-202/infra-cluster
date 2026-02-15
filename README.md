# Infra-Cluster

Repositório contendo a infraestrutura do cluster Kubernetes (EKS) na AWS, gerenciada com Terraform em arquitetura modular.

## 📋 Visão Geral

Este projeto provisiona e configura um cluster Amazon EKS (Elastic Kubernetes Service) completo na AWS, incluindo:

- Cluster EKS com controle de acesso configurado
- Node groups com auto-scaling
- Addons essenciais (ArgoCD, AWS Load Balancer Controller, External Secrets, etc.)
- Integração com monitoramento (Datadog)
- Configuração de IRSA (IAM Roles for Service Accounts)
- Políticas de recursos (LimitRange e ResourceQuota)

## 🏗️ Estrutura do Projeto

O projeto utiliza uma arquitetura modular com um root module orquestrador:

```
infra-cluster/
├── main.tf                      # Root module orquestrador
├── providers.tf                 # Configuração de providers (AWS, K8s, Helm)
├── backend.tf                   # Backend S3 único
├── variables.tf                 # Variáveis do root module
├── outputs.tf                   # Outputs do root module
├── data.tf                      # Data sources (infra-core remote state)
├── terraform.tfvars             # Valores das variáveis
│
├── modules/                     # Módulos reutilizáveis
│   ├── cluster/                # Módulo do cluster EKS
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── eks-roles.tf
│   │   ├── data.tf
│   │   └── modules/
│   │       └── eks/
│   │
│   ├── bootstrap-core/         # IRSA + Addons essenciais
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── irsa.tf
│   │   ├── addons.tf
│   │   └── data.tf
│   │
│   └── bootstrap-addons/       # Addons adicionais (Datadog, etc)
│       ├── variables.tf
│       ├── outputs.tf
│       ├── addons.tf
│       ├── k8s-manifests.tf
│       └── data.tf
│
└── terraform/                   # Diretório legado (manter para referência)
```

## 🔧 Pré-requisitos

Antes de começar, certifique-se de ter:

- **Terraform** >= 1.5.0 instalado
- **AWS CLI** configurado com credenciais válidas
- **kubectl** instalado (para interagir com o cluster após criação)
- **helm** instalado (opcional, mas recomendado)
- Acesso a uma conta AWS com permissões adequadas
- Um bucket S3 configurado para armazenar o estado do Terraform (`nextime-frame-state-bucket`)
- Uma infraestrutura de rede pré-existente (VPC e subnets) do `infra-core`

## 🚀 Como Usar

### Execução Unificada

Com a nova arquitetura modular, todo o processo é executado em um único comando:

```bash
# 1. Na raiz do projeto
cd infra-cluster

# 2. Inicializar
terraform init

# 3. Validar
terraform validate

# 4. Planejar
terraform plan -var-file=terraform.tfvars

# 5. Aplicar (cria cluster + bootstrap-core + bootstrap-addons)
terraform apply -var-file=terraform.tfvars
```

### O que acontece durante o apply:

1. **Módulo Cluster**: Cria o cluster EKS, roles IAM, security groups e node groups
2. **Módulo Bootstrap Core**: Configura IRSA e instala addons essenciais (ArgoCD, AWS LB Controller, External Secrets, EBS CSI, Metrics Server)
3. **Módulo Bootstrap Addons**: Instala Datadog e configura secrets/quotas

## 📦 Componentes Instalados

### Addons Core

| Componente | Versão | Descrição |
|------------|--------|-----------|
| **ArgoCD** | 7.6.0 | GitOps continuous delivery tool |
| **AWS Load Balancer Controller** | 1.7.2 | Gerencia Application Load Balancers e Network Load Balancers |
| **External Secrets Operator** | 0.9.20 | Sincroniza secrets de sistemas externos (AWS SSM, Secrets Manager) |
| **AWS EBS CSI Driver** | latest | Permite uso de volumes EBS persistentes |
| **Metrics Server** | latest | Coleta métricas de recursos (CPU, memória) dos pods |

### Addons Adicionais

| Componente | Descrição |
|------------|-----------|
| **Datadog** | Monitoramento completo (logs, APM, métricas, processos) |

### Configurações Kubernetes

- **LimitRange**: Define limites padrão de recursos para containers no namespace `default`
  - Default: 600m CPU / 800Mi memória
  - Default Request: 250m CPU / 400Mi memória
- **ResourceQuota**: Define quotas de recursos para o namespace `default`
  - CPU: 3000m requests / 3500m limits
  - Memória: 8Gi requests / 10Gi limits

## 🔐 Segurança

### IRSA (IAM Roles for Service Accounts)

O projeto utiliza IRSA para permitir que pods do Kubernetes assumam roles IAM específicas:

- **External Secrets**: Acesso ao AWS Systems Manager Parameter Store (`/datadog/*`)
- **AWS Load Balancer Controller**: Permissões para gerenciar ALBs/NLBs
- **EBS CSI Driver**: Permissões para criar e gerenciar volumes EBS

### Acesso ao Cluster

- **Endpoint privado**: Habilitado por padrão
- **Endpoint público**: Configurável via variáveis
- **CIDRs públicos**: Configurável via `public_access_cidrs`

## 📝 Variáveis Principais

### Root Module (`terraform.tfvars`)

```hcl
region      = "us-east-1"
environment = "dev"
project     = "nexTime-frame"

cluster_name    = "nextime-frame-cluster"
cluster_version = "1.29"

node_min_size       = 2
node_max_size       = 2
node_desired_size   = 2
node_instance_types = ["t3.large"]

endpoint_private_access = true
endpoint_public_access  = true
public_access_cidrs     = ["0.0.0.0/0"]

ami_type = "AL2_x86_64"

tags = {
  Environment = "dev"
  Project     = "nexTime-frame"
}
```

## 🔄 Dependências

O projeto depende de:

1. **Infraestrutura de Rede (infra-core)**: VPC e subnets devem existir e estar referenciadas no remote state:
   - Backend: `s3://nextime-frame-state-bucket/infra-core/infra.tfstate`
   - Outputs esperados:
     - `vpc_id`
     - `public_subnet_ids`

2. **Fluxo de Dependências entre Módulos**:
   ```
   infra-core (remote state)
        ↓
   module.cluster
        ↓
   module.bootstrap_core
        ↓
   module.bootstrap_addons
   ```

## 📊 Recursos de Monitoramento

### Datadog

O Datadog está configurado para coletar:
- **Logs**: Todos os containers (containerCollectAll: true)
- **APM**: Rastreamento de aplicações
- **Métricas**: Métricas de cluster, nodes e pods
- **Processos**: Informações de processos

A API key do Datadog deve estar armazenada no AWS SSM Parameter Store em:
- `/datadog/api-key`

O External Secrets Operator sincroniza automaticamente este valor para um Secret do Kubernetes.

## 🛠️ Manutenção

### Atualizar o Cluster

Para atualizar a versão do Kubernetes:

1. Atualize `cluster_version` em `terraform.tfvars`
2. Execute `terraform plan` e `terraform apply`

### Adicionar Novos Addons

1. Adicione o Helm release em `modules/bootstrap-core/addons.tf` ou `modules/bootstrap-addons/addons.tf`
2. Se necessário, configure IRSA em `modules/bootstrap-core/irsa.tf`
3. Execute `terraform apply`

### Escalar Nodes

Atualize as variáveis `node_min_size`, `node_max_size` e `node_desired_size` em `terraform.tfvars` e aplique as mudanças.

## 🧹 Limpeza

Para destruir a infraestrutura:

```bash
# Na raiz do projeto
terraform destroy -var-file=terraform.tfvars
```

**⚠️ Atenção**: Certifique-se de remover manualmente recursos que possam ter dependências (como volumes EBS persistentes) antes de destruir o cluster.

## 🏛️ Arquitetura Modular

### Vantagens da Nova Estrutura

✅ **Um único `terraform apply`** - tudo é orquestrado pelo root module  
✅ **Sem remote state entre módulos** - outputs passados via variáveis  
✅ **Dependências explícitas** - `depends_on` entre módulos  
✅ **Módulos reutilizáveis** - podem ser usados em outros projetos  
✅ **Providers centralizados** - configurados uma vez no root  
✅ **Backend único** - um state file para toda a infraestrutura do cluster  
✅ **infra-core intacto** - continua separado com seu próprio state  

### Como os Módulos se Comunicam

```terraform
# Root module (main.tf)
module "cluster" {
  source = "./modules/cluster"
  # ... variáveis
}

module "bootstrap_core" {
  source = "./modules/bootstrap-core"
  depends_on = [module.cluster]
  
  # Passa outputs do cluster via variáveis
  cluster_name              = module.cluster.cluster_name
  cluster_endpoint          = module.cluster.cluster_endpoint
  cluster_oidc_provider_arn = module.cluster.cluster_oidc_provider_arn
  # ...
}
```

## 📚 Referências

- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Modules](https://developer.hashicorp.com/terraform/language/modules)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [External Secrets Operator](https://external-secrets.io/)
- [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)

## 📄 Licença

Este projeto faz parte do hackathon SOAT.
