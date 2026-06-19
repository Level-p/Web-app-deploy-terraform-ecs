
# create aws provider
provider "aws" {
  region  = var.region
  profile = "default"
}

terraform {
  backend "s3" {
    bucket       = "varsitix-storage-bucket"
    # use_lockfile = true
    key          = "jenkins/terraform.tfstate"
    region       = "eu-west-2"
    encrypt      = true
    profile      = "default"
  }
}