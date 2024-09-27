output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
}

output "private_subnet_ids" {
  value = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
}

output "vpc_security_group_ids" {
  description = "ID of the security group"
  value       = [aws_security_group.lila_mongo_sg.id]
}

output "docdb_security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.docdb_sg.id
}

output "codebuild_security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.codebuild_sg.id
}
