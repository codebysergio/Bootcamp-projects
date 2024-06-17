resource "aws_vpc" "vpc" {
  cidr_block = var.cidr
}
resource "aws_subnet" "asg_sub" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.sub-cidr
  availability_zone = "us-west-2a"
}
resource "aws_launch_template" "blog-LT" {
  image_id      = var.ami
  instance_type = "t2.micro"
}
resource "aws_autoscaling_group" "blog-asg" {
  max_size            = 5
  min_size            = 1
  desired_capacity    = 1
  vpc_zone_identifier = [aws_subnet.asg_sub.id]


  launch_template {
    id      = aws_launch_template.blog-LT.id
    version = "$Latest"
  }
}