/****************INSTANCE VARIABLES*****************/
variable "ec2_server_port" {
  description = "The port of the server will use for HTTP requests"
  default = 8080
  type = number
}

variable "ec2_instance_type" {
  default = "t2.micro"
}

variable "ec2_ami" {
  default = "ami-052efd3df9dad4825"
}

variable "ec2_key_pair_name" {
  default = "sisoi-key-pair2"
}
/***************************PROVIDER CONFIGURATION********************************/
variable "provider_region" {
  default = "us-east-2"
}


/********************VPC CONFIGURING***********************/
variable "vpc_environment" {
  default = "dev"
}

variable "vpc_cidr" {
    type = string
    default = "10.0.0.0/16"
}

variable "vpc_public_subnets_cidr" {
  type = list(string)
  default = [ "10.0.0.0/24", "10.0.1.0/24", "10.0.2.0/24" ]
}

variable "vpc_private_subnets_cidr" {
  type = list(string)
  default = [ "10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24" ]
}

variable "vpc_availability_zones" {
  type = list(string)
  default = ["us-east-2a", "us-east-2b", "us-east-2c"]
}


/**********************RDS CONFIGURING*****************************/

variable db_identifier_prefix  {
  description = "The value for RDS DB configuration"
  default = "terraform-up-and-running"
  type = string
}  

variable db_engine             {
  description = "The value for RDS DB configuration"
  default = "mysql"
  type = string
} 

variable db_allocated_storage  {
  description = "The value for RDS DB configuration"
  default = 10
  type = string
}  

variable db_instance_class     {
  description = "The value for RDS DB configuration"
  default = "db.t2.micro"
  type = string
}  

variable db_multi_az           {
  description = "The value for RDS DB configuration"
  default = true
  type = bool
}  

variable db_name               {
  description = "The value for RDS DB configuration"
  default = "example_database"
  type = string
}  

variable db_username           {
  description = "The value for RDS DB configuration"
  default = "admin"
  type = string
}  

variable "db_password" {
  description   = "The password to MySQL DB user"
  default       = "password1234"
  type          = string
}
