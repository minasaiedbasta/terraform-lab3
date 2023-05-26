output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "az1_public_subnet" {
  value = aws_subnet.az1_public_subnet
}

output "az1_private_subnet" {
  value = aws_subnet.az1_private_subnet
}

output "az2_public_subnet" {
  value = aws_subnet.az2_public_subnet
}

output "az2_private_subnet" {
  value = aws_subnet.az2_private_subnet
}