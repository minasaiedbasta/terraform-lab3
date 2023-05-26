output "private_load_balancer_dns" {
  value = aws_lb.private_load_balancer.dns_name
}

output "public_load_balancer_dns" {
  value = aws_lb.public_load_balancer.dns_name
}

output "public_lb_sg_id" {
  value = aws_security_group.public_lb_sg.id
}

output "private_lb_sg_id" {
  value = aws_security_group.private_lb_sg.id
}