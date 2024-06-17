output "ec2-ip" {
  description = "ec2-public-ip"
  value       = aws_instance.ec2-instance.public_ip
}
output "db_instance_endpoint" {
  description = "db api"
  value       = aws_db_instance.myinstance.endpoint
}