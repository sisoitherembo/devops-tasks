locals {
  http_port     = 80
  ssh_port      = 22
  any_port      = 0
  tcp_protocol  = "tcp"
  any_protocol  = "-1"
  cidr_blocks   = ["0.0.0.0/0"]
  any_cidr      = ["0.0.0.0/0"]
}