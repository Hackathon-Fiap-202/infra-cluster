# Outputs do Bootstrap Addons
output "datadog_release_status" {
  description = "Status do release do Datadog"
  value       = helm_release.datadog.status
}

