output "nginx_sg_id" {
  value = aws_security_group.nginx_sg.id
}

output "az1_public_instance_id" {
  value = aws_instance.az1_public_instance.id
}

output "az2_public_instance_id" {
  value = aws_instance.az2_public_instance.id
}

output "az1_private_instance_id" {
  value = aws_instance.az1_private_instance.id
}

output "az2_private_instance_id" {
  value = aws_instance.az2_private_instance.id
}