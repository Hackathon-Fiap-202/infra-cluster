# -----------------------------------------------------------------------------
# Configurações Gerais
# -----------------------------------------------------------------------------
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

# -----------------------------------------------------------------------------
# Configurações do Bucket de State (infra-core)
# -----------------------------------------------------------------------------
variable "state_bucket" {
  description = "S3 bucket para terraform state"
  type        = string
}

variable "state_key_infra_core" {
  description = "Key do state do infra-core no S3"
  type        = string
  default     = "infra-core/infra.tfstate"
}

# -----------------------------------------------------------------------------
# Configurações do Cluster EKS
# -----------------------------------------------------------------------------
variable "cluster_name" {
  description = "Nome do cluster EKS"
  type        = string
}

variable "cluster_version" {
  description = "Versão do Kubernetes"
  type        = string
  default     = "1.29"
}

# -----------------------------------------------------------------------------
# Configurações dos Nodes
# -----------------------------------------------------------------------------
variable "node_min_size" {
  description = "Número mínimo de nodes no node group"
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Número máximo de nodes no node group"
  type        = number
  default     = 4
}

variable "node_desired_size" {
  description = "Número desejado de nodes no node group"
  type        = number
  default     = 2
}

variable "node_instance_types" {
  description = "Tipos de instância EC2 para os nodes"
  type        = list(string)
  default     = ["t3.large"]
}

variable "ami_type" {
  description = "Tipo de AMI para os nodes"
  type        = string
  default     = "AL2_x86_64"
}

# -----------------------------------------------------------------------------
# Configurações de Acesso ao Cluster
# -----------------------------------------------------------------------------
variable "endpoint_private_access" {
  description = "Habilita acesso privado ao endpoint do cluster"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Habilita acesso público ao endpoint do cluster"
  type        = bool
  default     = true
}

variable "public_access_cidrs" {
  description = "CIDRs autorizados a acessar o endpoint público"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# -----------------------------------------------------------------------------
# Controle de Bootstrap
# -----------------------------------------------------------------------------
variable "enable_bootstrap_addons" {
  description = "Habilita criação dos módulos bootstrap (bootstrap-core e bootstrap-addons). Deve ser false no primeiro apply."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Tags
# -----------------------------------------------------------------------------
variable "tags" {
  description = "Tags comuns para todos os recursos"
  type        = map(string)
  default     = {}
}

