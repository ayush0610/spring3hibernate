terraform {
  backend "s3" {
    bucket = "ayush-terraform-state"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}