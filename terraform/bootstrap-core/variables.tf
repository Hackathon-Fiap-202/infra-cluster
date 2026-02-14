variable "region" {
  type    = string
  default = "us-east-1"
}

variable "environment" {
  type = string
}

variable "project" {
  type = string
}

variable "cluster_name" {
  description = "Nome do cluster EKS"
  type        = string
}