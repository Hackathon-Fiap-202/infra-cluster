data "terraform_remote_state" "infra_core" {
  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = var.state_key_infra_core
    region = var.region
  }
}

