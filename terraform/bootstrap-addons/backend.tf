terraform {
  backend "s3" {
    bucket  = "nextime-frame-state-bucket"
    key     = "infra-kubernetes/bootstrap-addons.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
