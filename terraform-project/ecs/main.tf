resource "aws_ecs_cluster" "lila_cluster" {
  name = "lila-cluster"
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "ecs_task_docdb_policy" {
  role = aws_iam_role.ecs_task_execution_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "docdb:Connect",
          "docdb:DescribeDBInstances"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_cloudwatch_log_group" "lila_log_group" {
  name              = "lila-log-group"
  retention_in_days = 7  # Задайте необхідний термін зберігання
}

resource "aws_ecs_task_definition" "lila_task" {
  family                   = "lila-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"] 
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  cpu                      = "1024"
  memory                   = "2048"
  
  container_definitions = jsonencode([{
    name      = "lila"
    image     = "tarashoshko/lila:latest"
    essential = true
    portMappings = [{
      containerPort = 9663
      hostPort      = 9663
      protocol      = "tcp"
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        "awslogs-group"         = aws_cloudwatch_log_group.lila_log_group.name
        "awslogs-region"        = "eu-central-1"
        "awslogs-stream-prefix" = "lila"
      }
    }
    environment = [
      {
        name  = "LILA_DOMAIN"
        value = var.lila_domain
      },
      {
        name  = "REDIS_DOMAIN"
        value = var.redis_domain
      },
      {
        name  = "MONGO_DOMAIN"
	value = var.mongo_domain
      }
    ]
  }])
}

resource "aws_ecs_service" "lila_service" {
  name            = "lila-service"
  cluster         = aws_ecs_cluster.lila_cluster.id
  task_definition = aws_ecs_task_definition.lila_task.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = var.security_group_ids
    assign_public_ip = true
  }
}

resource "aws_lb" "lila_lb" {
  name               = "lila-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.public_subnet_ids
}

resource "aws_lb_listener" "lila_listener" {
  load_balancer_arn = aws_lb.lila_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.lila_target_group.arn
  }
}

resource "aws_lb_target_group" "lila_target_group" {
  name     = "lila-target-group"
  port     = 9663
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold  = 2
    unhealthy_threshold = 2
  }
}

resource "aws_security_group" "ecs_sg" {
  name        = "ecs-sg"
  description = "Security Group for ECS tasks"
  vpc_id      = var.vpc_id

  tags = {
    Name = "ecs-sg"
  }
}

