resource "aws_vpc" "vpc" {
  cidr_block = var.cidr
}
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.public-cidr
  availability_zone = "us-west-2a"
}
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private-cidr
  availability_zone = "us-west-2c"
}
resource "aws_subnet" "private-2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.private-cidr-2
  availability_zone = "us-west-2a"
}
resource "aws_security_group" "main_sg" {
  name   = "ec2_sg"
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_instance" "ec2-instance" {
  instance_type               = var.instance-type
  ami                         = var.ec2-ami
  vpc_security_group_ids      = [aws_security_group.main_sg.id]
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.public.id
  availability_zone = "us-west-2a"
}
resource "aws_db_instance" "myinstance" {
  engine                 = "mysql"
  multi_az               = false
  identifier             = "myrdsinstance"
  allocated_storage      = 20
  engine_version         = "8.0.35"
  instance_class         = "db.t3.micro"
  username               = var.db-username
  password               = var.db-password
  parameter_group_name   = "default.mysql8.0"
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.db-subnet-group.id
}
resource "aws_security_group" "rds_sg" {
  name   = "rds_sg"
  vpc_id = aws_vpc.vpc.id
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.main_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_db_subnet_group" "db-subnet-group" {
  name       = "main"
  subnet_ids = [aws_subnet.private-2.id, aws_subnet.private.id]

  tags = {
    Name = "My DB subnet group"
  }
}