output "private_server_private_ip" {
  value = aws_instance.private_server.private_ip
}

output "private_server_private_dns" {
  value = aws_instance.private_server.private_dns
}

output "private_server_tags" {
  value = aws_instance.private_server.tags
}

output "bastion_server_dns" {
  value = aws_instance.bastion_server.public_dns
}

output "bastion_server_public_ip" {
  value = aws_instance.bastion_server.public_ip
}

output "bastion_server_private_ip" {
  value = aws_instance.bastion_server.private_ip
}

output "bastion_server_tags" {
  value = aws_instance.bastion_server.tags
}

output "db_address" {
  value = module.database.address
}

output "db_port" {
  value = module.database.port
}

output "vpc_id" {
  value = module.networking.vpc_id
}

output "public_subnet_ids" {
  value = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.networking.private_subnet_ids
}

output "security_group_id" {
  value = module.networking.security_group_id
}

output "vpc_name" {
  value = module.networking.vpc_name
}

output "public_subnet_names" {
  value = module.networking.public_subnet_names
}

output "private_subnet_names" {
  value = module.networking.private_subnet_names
}

output "security_group_name" {
  value = module.networking.security_group_name
}