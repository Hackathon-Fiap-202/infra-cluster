# Outputs do Bootstrap Core
output "aws_lb_controller_role_arn" {
  description = "ARN da role IAM do AWS Load Balancer Controller"
  value       = aws_iam_role.aws_lb_controller.arn
}

output "external_secrets_role_arn" {
  description = "ARN da role IAM do External Secrets"
  value       = aws_iam_role.external_secrets.arn
}

output "ebs_csi_role_arn" {
  description = "ARN da role IAM do EBS CSI Driver"
  value       = aws_iam_role.ebs_csi.arn
}

