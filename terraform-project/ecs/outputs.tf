output "ecs_sg_id" {
  description = "The ID of the Security Group for ECS"
  value       = aws_security_group.ecs_sg.id  # Або яке ім'я ви використовуєте для SG ECS
}

