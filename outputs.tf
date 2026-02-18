# -----------------------------------------------------------------------------
# Outputs do Cluster
# -----------------------------------------------------------------------------
output "cluster_name" {
  description = "Nome do cluster EKS"
  value       = module.cluster.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint do cluster EKS"
  value       = module.cluster.cluster_endpoint
}

output "cluster_oidc_provider_arn" {
  description = "ARN do OIDC provider do cluster"
  value       = module.cluster.cluster_oidc_provider_arn
}

output "cluster_oidc_provider_url" {
  description = "URL do OIDC provider do cluster"
  value       = module.cluster.cluster_oidc_provider_url
}

# -----------------------------------------------------------------------------
# Outputs do Infra Core (da VPC)
# -----------------------------------------------------------------------------
output "vpc_id" {
  description = "ID da VPC"
  value       = local.vpc_id
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas"
  value       = local.public_subnet_ids
}

# -----------------------------------------------------------------------------
# Outputs do Bootstrap Core
# -----------------------------------------------------------------------------
# CONDICIONAL: Só expõe outputs quando bootstrap está habilitado
output "aws_lb_controller_role_arn" {
  description = "ARN da role IAM do AWS Load Balancer Controller"
  value       = var.enable_bootstrap_addons ? module.bootstrap_core[0].aws_lb_controller_role_arn : null
}

output "external_secrets_role_arn" {
  description = "ARN da role IAM do External Secrets"
  value       = var.enable_bootstrap_addons ? module.bootstrap_core[0].external_secrets_role_arn : null
}

output "ebs_csi_role_arn" {
  description = "ARN da role IAM do EBS CSI Driver"
  value       = var.enable_bootstrap_addons ? module.bootstrap_core[0].ebs_csi_role_arn : null
}

