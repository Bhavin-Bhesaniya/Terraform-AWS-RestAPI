terraform {
  backend "s3" {
    bucket = "restapi-bucket-state"
    key    = "restapi/jenkins/terraform.tfstate"
    region = "ap-south-1"
  }
}