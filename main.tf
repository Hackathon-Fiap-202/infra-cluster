# ==================================================
# Root Module - Orquestração de todos os módulos
# ==================================================

locals {
  # Data source do infra-core (mantém remote state)
  vpc_id            = data.terraform_remote_state.infra_core.outputs.vpc_id
  public_subnet_ids = data.terraform_remote_state.infra_core.outputs.public_subnet_ids
}

# --------------------------------------------------
# Módulo Cluster EKS
# --------------------------------------------------
module "cluster" {
  source = "./modules/cluster"

  region              = var.region
  environment         = var.environment
  cluster_name        = var.cluster_name
  cluster_version     = var.cluster_version
  ami_type            = var.ami_type
  
  endpoint_private_access = var.endpoint_private_access
  endpoint_public_access  = var.endpoint_public_access
  public_access_cidrs     = var.public_access_cidrs
  
  node_min_size       = var.node_min_size
  node_max_size       = var.node_max_size
  node_desired_size   = var.node_desired_size
  node_instance_types = var.node_instance_types
  
  # Passa dados do infra-core
  vpc_id            = local.vpc_id
  public_subnet_ids = local.public_subnet_ids
  
  tags = var.tags
}

# --------------------------------------------------
# Módulo Bootstrap Core (IRSA + Addons Core)
# --------------------------------------------------
module "bootstrap_core" {
  source = "./modules/bootstrap-core"
  
  depends_on = [module.cluster]
  
  region      = var.region
  environment = var.environment
  project     = var.project
  
  # Passa outputs do cluster
  cluster_name              = module.cluster.cluster_name
  cluster_endpoint          = module.cluster.cluster_endpoint
  cluster_ca                = module.cluster.cluster_ca
  cluster_oidc_provider_arn = module.cluster.cluster_oidc_provider_arn
  cluster_oidc_provider_url = module.cluster.cluster_oidc_provider_url
  
  # Passa dados do infra-core
  vpc_id = local.vpc_id
}

# --------------------------------------------------
# Módulo Bootstrap Addons (Datadog, Secrets, etc)
# --------------------------------------------------
module "bootstrap_addons" {
  source = "./modules/bootstrap-addons"
  
  depends_on = [module.bootstrap_core]
  
  region      = var.region
  environment = var.environment
  project     = var.project
  
  # Passa outputs do cluster
  cluster_name = module.cluster.cluster_name
}
