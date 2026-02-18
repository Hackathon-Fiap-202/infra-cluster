terraform {
  backend "s3" {
    bucket = "nextime-frame-state-bucket"
    key    = "infra-kubernetes/infra.tfstate"
    region = "us-east-1"
  }
}

