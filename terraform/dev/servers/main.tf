terraform {
  backend "s3" {
    bucket          = "sisoitherembo-terraform-state-bucket"
    key             = "dev/services/frontend-app/terraform.tfstate"
    region          = "us-east-2"

    dynamodb_table  = "sisoitherembo-terraform-state-bucket-locks"
    encrypt         = true
  }
}

module "database" {
  source = "../data-storage"
  
  region                = var.provider_region
  identifier_prefix     = var.db_identifier_prefix 
  engine                = var.db_engine
  allocated_storage     = var.db_allocated_storage
  instance_class        = var.db_instance_class
  multi_az              = var.db_multi_az
  name                  = var.db_name
  username              = var.db_username
  password              = var.db_password
}

module "networking" {
  source = "../networking"

  region               = var.provider_region
  vpc_cidr             = "${var.vpc_cidr}"
  environment          = "${var.vpc_environment}"
  public_subnets_cidr  = "${var.vpc_public_subnets_cidr}"
  private_subnets_cidr = "${var.vpc_private_subnets_cidr}"
  availability_zones   = "${var.vpc_availability_zones}"
}

provider "aws" {
  region = var.provider_region
}

resource "aws_instance" "private_server" {
  ami                     = data.aws_ami.ubuntu-linux.id
  instance_type           = var.ec2_instance_type
  vpc_security_group_ids  = [ module.networking.security_group_id ]
  subnet_id               = module.networking.private_subnet_ids[0] 
  key_name                = var.ec2_key_pair_name

  depends_on = [
    module.networking,
    module.database
  ]

  user_data = data.template_file.user_data.rendered

  tags = {
    "Name" = "${var.vpc_environment}-private_server_terraform"
  }
}


resource "aws_instance" "bastion_server" {
  ami                     = data.aws_ami.ubuntu-linux.id
  instance_type           = var.ec2_instance_type
  vpc_security_group_ids  = [ module.networking.security_group_id ]
  subnet_id               = module.networking.public_subnet_ids[0] 
  key_name                = var.ec2_key_pair_name

  depends_on = [ 
    module.networking,
    module.database
  ]

  user_data               = data.template_file.user_data.rendered

  tags = {
    "Name" = "${var.vpc_environment}-bastion_server_terraform"
  }
}
