# Data source do infra-core (único remote state mantido)
data "terraform_remote_state" "infra_core" {
  backend = "s3"
  config = {
    bucket = var.state_bucket
    key    = "infra-core/infra.tfstate"
    region = var.region
  }
}

# Data sources do cluster EKS (lidos após cluster ser criado)
# Estes data sources são usados pelos providers kubernetes e helm
data "aws_eks_cluster" "this" {
  name = module.cluster.cluster_name
  
  depends_on = [module.cluster]
}

data "aws_eks_cluster_auth" "this" {
  name = module.cluster.cluster_name
  
  depends_on = [module.cluster]
}

# Caller identity para uso nos módulos
data "aws_caller_identity" "current" {}
