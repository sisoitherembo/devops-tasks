
provider "aws" {
    access_key = "AKIATSQNSBNZJ5Q5KH7P"
    secret_key = "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"
    region = var.provider_region
}

resource "aws_instance" "private_server" {
  ami                     = "ami-08c40ec9ead489470"
  instance_type           = "t2.micro"
  subnet_id               = var.subnet_id
  tags = {
    "Name" = "my-private_server_terraform"
  }
}
