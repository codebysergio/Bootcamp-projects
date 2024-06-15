resource "aws_vpc" "vpc" {
  cidr_block = var.cidr
}
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.public-cidr
}
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.private-cidr
}
resource "aws_security_group" "main-sg" {
  name   = var.sg-name
  vpc_id = aws_vpc.vpc.id
}
resource "aws_vpc_security_group_ingress_rule" "name" {
  security_group_id = aws_security_group.main-sg.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4 = "0.0.0.0/0"
}