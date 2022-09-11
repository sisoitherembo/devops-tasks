terraform {
  backend "s3" {
    bucket = "sisoitherembo-terraform-state-bucket"
    key = "global/s3/terraform.tfstate"
    region = "us-east-2"

    dynamodb_table = "sisoitherembo-terraform-state-bucket-locks"
    encrypt = true
  }
}

provider "aws" {
  region = "us-east-2"
}


resource "aws_s3_bucket" "terraform_state" {
  bucket = "sisoitherembo-terraform-state-bucket"

  lifecycle {
    prevent_destroy = true
  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule{
        apply_server_side_encryption_by_default {
          sse_algorithm = "AES256"
        }
    }
  }
}


resource "aws_dynamodb_table" "terraform_locks" {
  name          = "sisoitherembo-terraform-state-bucket-locks"
  billing_mode  = "PAY_PER_REQUEST"
  hash_key      = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  } 
}
