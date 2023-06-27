terraform {
  backend "s3" {
    bucket         = "khanhtq34-assignment3-terraform-bucket"
    key            = "lab/terraform.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
    #dynamodb_table = "backend-table"
  }
}