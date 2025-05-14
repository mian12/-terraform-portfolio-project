terraform {
  backend "s3" {
    bucket = "ss-my-tf-state-01"
    key = "global/s3/terraform.tfstate"
    region = "eu-north-1"
    dynamodb_table = "terraform-lock-file"
  }
}