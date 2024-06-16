output "ec2-ip" {
  description = "ec2-public-ip"
  value = aws_instance.ec2-instance.public_ip
}