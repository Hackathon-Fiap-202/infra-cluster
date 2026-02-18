# -----------------------------------------------------------------------------
# Locals - Dados do infra-core via remote state
# -----------------------------------------------------------------------------
locals {
  vpc_id             = data.terraform_remote_state.infra_core.outputs.vpc_id
  public_subnet_ids  = data.terraform_remote_state.infra_core.outputs.public_subnet_ids
}

# -----------------------------------------------------------------------------
# MÓDULO 1: Cluster EKS
# -----------------------------------------------------------------------------
module "cluster" {
  source = "./modules/cluster"

  # Configurações básicas
  region      = var.region
  environment = var.environment
  project     = var.project

  # Configurações do cluster
  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  # Rede (do infra-core)
  vpc_id            = local.vpc_id
  public_subnet_ids = local.public_subnet_ids

  # Configurações dos nodes
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size
  node_desired_size   = var.node_desired_size
  node_instance_types = var.node_instance_types

  # Acesso ao cluster
  endpoint_private_access = var.endpoint_private_access
  endpoint_public_access  = var.endpoint_public_access
  public_access_cidrs     = var.public_access_cidrs

  # AMI
  ami_type = var.ami_type

  # Tags
  tags = var.tags
}

# -----------------------------------------------------------------------------
# MÓDULO 2: Bootstrap Core (IRSA + Addons Essenciais)
# -----------------------------------------------------------------------------
module "bootstrap_core" {
  source = "./modules/bootstrap-core"

  # Dependência explícita: aguarda cluster ser criado
  depends_on = [module.cluster]

  # Configurações básicas
  region      = var.region
  environment = var.environment
  project     = var.project

  # Outputs do cluster passados como variáveis (elimina remote_state)
  cluster_name              = module.cluster.cluster_name
  cluster_endpoint          = module.cluster.cluster_endpoint
  cluster_ca                = module.cluster.cluster_ca
  cluster_oidc_provider_arn = module.cluster.cluster_oidc_provider_arn
  cluster_oidc_provider_url = module.cluster.cluster_oidc_provider_url

  # VPC ID (pode ser necessário para alguns addons)
  vpc_id = local.vpc_id
}

# -----------------------------------------------------------------------------
# MÓDULO 3: Bootstrap Addons (Datadog, Secrets, etc)
# -----------------------------------------------------------------------------
module "bootstrap_addons" {
  source = "./modules/bootstrap-addons"

  # Dependência explícita: aguarda bootstrap_core ser criado
  depends_on = [module.bootstrap_core]

  # Configurações básicas
  region      = var.region
  environment = var.environment
  project     = var.project

  # Outputs do cluster passados como variáveis (elimina remote_state)
  cluster_name = module.cluster.cluster_name
}

