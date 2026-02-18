variable "region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

# Output do cluster passado como variável (elimina remote_state)
variable "cluster_name" {
  description = "Nome do cluster EKS"
  type        = string
}