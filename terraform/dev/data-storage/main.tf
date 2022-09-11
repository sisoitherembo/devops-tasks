/* terraform {
  backend "s3" {
    bucket  = "sisoitherembo-terraform-state-bucket"
    key     = "dev/data-storage/terraform.tfstate"
    region  = "us-east-2"

    dynamodb_table = "sisoitherembo-terraform-state-bucket-locks"
    encrypt = true
  }
}
 */
 
provider "aws" {
  region = var.region
}

resource "aws_db_instance" "mysql_db" {
  identifier_prefix     = var.identifier_prefix 
  engine                = var.engine
  allocated_storage     = var.allocated_storage
  instance_class        = var.instance_class
  multi_az              = var.multi_az
  name                  = var.name
  username              = var.username
  password              = var.password
  skip_final_snapshot   = true
}