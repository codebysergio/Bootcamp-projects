resource "aws_vpc" "vpc" {
  cidr_block = var.cidr
}
resource "aws_subnet" "alb-sub" {
  vpc_id            = aws_vpc.vpc.id
  count             = length(var.vpc-azs)
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index + 3)
  availability_zone = element(var.vpc-azs, count.index)
}

resource "aws_subnet" "asg_sub" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.sub-cidr
  availability_zone = "us-west-2a"
}
resource "aws_security_group" "alb" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "asg" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  depends_on = [aws_security_group.alb]
}
resource "aws_lb" "alb" {
  load_balancer_type = "application"
  internal           = false
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.alb-sub[*].id
  depends_on = [ aws_internet_gateway.igw ]
}
resource "aws_lb_target_group" "alb-tg" {
  name     = "alb-tg"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
}
resource "aws_lb_listener" "name" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb-tg.arn
  }
}
resource "aws_launch_template" "blog-LT" {
  image_id      = var.ami
  instance_type = "t2.micro"

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.asg.id]
  }

  user_data = filebase64("test-script.sh")
}
resource "aws_autoscaling_group" "blog-asg" {
  max_size            = 5
  min_size            = 1
  desired_capacity    = 1
  vpc_zone_identifier = [aws_subnet.asg_sub.id]
  target_group_arns   = [aws_lb_target_group.alb-tg.arn]


  launch_template {
    id      = aws_launch_template.blog-LT.id
    version = "$Latest"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}
resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}
resource "aws_route_table_association" "rta" {
  route_table_id = aws_route_table.RT.id
  count          = length(var.vpc-azs)
  subnet_id      = element(aws_subnet.alb-sub[*].id, count.index)
}
resource "aws_eip" "eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw]
}
