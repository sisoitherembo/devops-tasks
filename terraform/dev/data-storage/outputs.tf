output "address" {
    description = "The IP address of the DB instance"
    value = aws_db_instance.mysql_db.address
}

output "port" {
  description = "Port of the DB instance"
  value = aws_db_instance.mysql_db.port
}