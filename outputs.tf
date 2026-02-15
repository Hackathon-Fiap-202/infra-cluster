output "cluster_name" {
  description = "Nome do cluster EKS"
  value       = module.cluster.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint do cluster EKS"
  value       = module.cluster.cluster_endpoint
}

output "cluster_oidc_provider_arn" {
  description = "ARN do OIDC Provider"
  value       = module.cluster.cluster_oidc_provider_arn
}

output "vpc_id" {
  description = "ID da VPC"
  value       = local.vpc_id
}

