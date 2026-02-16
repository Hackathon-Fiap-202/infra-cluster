terraform {
  backend "s3" {
    bucket  = "nextime-frame-state-bucket"
    key     = "infra-kubernetes/cluster-unified.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}


