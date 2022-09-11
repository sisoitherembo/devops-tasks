variable "region" {
  default = "us-east-2"
}

variable "password" {
  description   = "The password to MySQL DB user"
  default       = "password1234"
  type          = string
}

variable identifier_prefix  {
  description = "The value for RDS DB configuration"
  default = "terraform-up-and-running"
  type = string
}  

variable engine             {
  description = "The value for RDS DB configuration"
  default = "mysql"
  type = string
} 

variable allocated_storage  {
  description = "The value for RDS DB configuration"
  default = 10
  type = string
}  

variable instance_class     {
  description = "The value for RDS DB configuration"
  default = "db.t2.micro"
  type = string
}  

variable multi_az           {
  description = "The value for RDS DB configuration"
  default = true
  type = string
}  

variable name               {
  description = "The value for RDS DB configuration"
  default = "example_database"
  type = string
}  

variable username           {
  description = "The value for RDS DB configuration"
  default = "admin"
  type = string
}  
