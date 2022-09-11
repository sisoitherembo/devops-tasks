
data "template_file" "user_data"{
    template = file("${path.module}/user-data.sh")

    vars = {
        server_port  = var.ec2_server_port
        db_address   = module.database.address
        db_port      = module.database.port
    }
}

# Getting linux image
data "aws_ami" "ubuntu-linux" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/*-20.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}