output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "public_subnet_ids" {
  value = "${aws_subnet.public_subnet[*].id}"
}

output "private_subnet_ids" {
  value = "${aws_subnet.private_subnet[*].id}"
}

output "security_group_id" {
  value = "${aws_security_group.default.id}"
}

output "vpc_name" {
  value = "${aws_vpc.vpc.tags.Name}"
}

output "public_subnet_names" {
  value = "${aws_subnet.public_subnet[*].tags.Name}"
}

output "private_subnet_names" {
  value = "${aws_subnet.private_subnet[*].tags.Name}"
}

output "security_group_name" {
  value = "${aws_security_group.default.tags.Name}"
}