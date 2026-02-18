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
output "aws_lb_controller_role_arn" {
  description = "ARN da role IAM do AWS Load Balancer Controller"
  value       = module.bootstrap_core.aws_lb_controller_role_arn
}

output "external_secrets_role_arn" {
  description = "ARN da role IAM do External Secrets"
  value       = module.bootstrap_core.external_secrets_role_arn
}

output "ebs_csi_role_arn" {
  description = "ARN da role IAM do EBS CSI Driver"
  value       = module.bootstrap_core.ebs_csi_role_arn
}

