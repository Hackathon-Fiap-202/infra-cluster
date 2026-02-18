# Infra-Cluster

Repositório contendo a infraestrutura do cluster Kubernetes (EKS) na AWS, gerenciada com Terraform.

## 📋 Visão Geral

Este projeto provisiona e configura um cluster Amazon EKS (Elastic Kubernetes Service) completo na AWS, incluindo:

- Cluster EKS com controle de acesso configurado
- Node groups com auto-scaling
- Addons essenciais (ArgoCD, AWS Load Balancer Controller, External Secrets, etc.)
- Integração com monitoramento (Datadog)
- Configuração de IRSA (IAM Roles for Service Accounts)
- Políticas de recursos (LimitRange e ResourceQuota)

## 🏗️ Estrutura do Projeto

O projeto está organizado em três módulos principais que devem ser executados em ordem:

```
terraform/
├── cluster/              # Módulo principal - Cria o cluster EKS
│   ├── modules/
│   │   └── eks/         # Módulo reutilizável para criação do EKS
│   ├── main.tf          # Configuração do cluster e security groups
│   ├── eks-roles.tf     # IAM roles para cluster e nodes
│   ├── variables.tf     # Variáveis do módulo cluster
│   └── terraform.tfvars # Valores das variáveis
│
├── bootstrap-core/       # Configuração inicial - IRSA e addons essenciais
│   ├── irsa.tf          # IAM Roles for Service Accounts
│   ├── addons.tf        # Helm releases dos addons core
│   ├── variables.tf
│   └── terraform.tfvars
│
└── bootstrap-addons/     # Addons adicionais e configurações
    ├── addons.tf        # Helm releases dos addons (Datadog)
    ├── k8s-manifests.tf # Manifestos Kubernetes (External Secrets, LimitRange, ResourceQuota)
    ├── variables.tf
    └── terraform.tfvars
```

## 🔧 Pré-requisitos

Antes de começar, certifique-se de ter:

- **Terraform** >= 1.5.0 instalado
- **AWS CLI** configurado com credenciais válidas
- **kubectl** instalado (para interagir com o cluster após criação)
- **helm** instalado (opcional, mas recomendado)
- Acesso a uma conta AWS com permissões adequadas
- Um bucket S3 configurado para armazenar o estado do Terraform (`nextime-frame-state-bucket`)
- Uma infraestrutura de rede pré-existente (VPC e subnets) referenciada via remote state

## 🚀 Como Usar

### 1. Configurar o Backend do Terraform

Todos os módulos utilizam backend S3. Certifique-se de que o bucket `nextime-frame-state-bucket` existe na região `us-east-1`.

### 2. Criar o Cluster EKS

```bash
cd terraform/cluster
terraform init
terraform plan
terraform apply
```

Este módulo cria:
- Cluster EKS
- IAM roles para cluster e nodes
- Security groups
- Node group com auto-scaling

### 3. Configurar Addons Core (IRSA e Addons Essenciais)

```bash
cd terraform/bootstrap-core
terraform init
terraform plan
terraform apply
```

Este módulo configura:
- IRSA (IAM Roles for Service Accounts) para:
  - External Secrets
  - AWS Load Balancer Controller
  - EBS CSI Driver
- Instala via Helm:
  - ArgoCD (v7.6.0)
  - AWS Load Balancer Controller (v1.7.2)
  - External Secrets Operator (v0.9.20)
  - AWS EBS CSI Driver
  - Metrics Server

### 4. Instalar Addons Adicionais

```bash
cd terraform/bootstrap-addons
terraform init
terraform plan
terraform apply
```

Este módulo instala:
- Datadog Agent (monitoramento completo)
- Configura ClusterSecretStore para AWS SSM Parameter Store
- Cria ExternalSecret para Datadog API Key
- Define LimitRange e ResourceQuota para o namespace default

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

### Cluster (`terraform/cluster/terraform.tfvars`)

```hcl
region              = "us-east-1"
environment         = "dev"
cluster_name        = "nextime-frame-cluster"
cluster_version     = "1.29"
node_min_size       = 2
node_max_size       = 2
node_desired_size   = 2
node_instance_types = ["t3.large"]
endpoint_private_access = true
endpoint_public_access  = true
public_access_cidrs     = ["0.0.0.0/0"]
ami_type                = "AL2_x86_64"
```

### Bootstrap Core/Addons

```hcl
region      = "us-east-1"
environment = "dev"
project      = "nexTime-frame"
```

## 🔄 Dependências

O projeto depende de:

1. **Infraestrutura de Rede**: VPC e subnets devem existir e estar referenciadas no remote state:
   - Backend: `s3://nextime-frame-state-bucket/infra-core/infra.tfstate`
   - Outputs esperados:
     - `vpc_id`
     - `public_subnet_ids`

2. **Remote States**: Os módulos utilizam remote states para compartilhar informações:
   - `bootstrap-core` depende do estado do `cluster`
   - `bootstrap-addons` depende dos estados do `cluster` e `bootstrap-core`

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

1. Atualize `cluster_version` em `terraform/cluster/terraform.tfvars`
2. Execute `terraform plan` e `terraform apply` no módulo `cluster`

### Adicionar Novos Addons

1. Adicione o Helm release em `terraform/bootstrap-core/addons.tf` ou `terraform/bootstrap-addons/addons.tf`
2. Se necessário, configure IRSA em `terraform/bootstrap-core/irsa.tf`
3. Execute `terraform apply` no módulo correspondente

### Escalar Nodes

Atualize as variáveis `node_min_size`, `node_max_size` e `node_desired_size` em `terraform/cluster/terraform.tfvars` e aplique as mudanças.

## 🧹 Limpeza

Para destruir a infraestrutura, execute `terraform destroy` na ordem inversa:

```bash
cd terraform/bootstrap-addons
terraform destroy

cd ../bootstrap-core
terraform destroy

cd ../cluster
terraform destroy
```

**⚠️ Atenção**: Certifique-se de remover manualmente recursos que possam ter dependências (como volumes EBS persistentes) antes de destruir o cluster.

## 📚 Referências

- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [External Secrets Operator](https://external-secrets.io/)
- [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/)

## 📄 Licença

Este projeto faz parte do hackathon SOAT.
