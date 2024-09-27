resource "aws_iam_role" "codebuild_service_role" {
  name = "codebuild-service-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
	Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
        Sid       = ""
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_ec2_full_access" {
  role       = aws_iam_role.codebuild_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "codebuild_s3_full_access" {
  role       = aws_iam_role.codebuild_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "codebuild_codebuild_full_access" {
  role       = aws_iam_role.codebuild_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess"
}

resource "aws_iam_role_policy" "codebuild_policy" {
  role = aws_iam_role.codebuild_service_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "s3:GetObject",
          "s3:PutObject",
	  "ec2:DescribeSecurityGroups",
	  "ec2:DescribeSubnets",
          "ec2:DescribeNetworkInterfaces",
	  "ec2:DeleteNetworkInterface",  
          "ec2:CreateNetworkInterface",   
          "ec2:AttachNetworkInterface",    
          "ec2:DetachNetworkInterface",
	  "ec2:DescribeVpcs",              # Додано
          "ec2:DescribeRouteTables",       # Додано
          "ec2:DescribeNetworkAcls",       # Додано
          "ec2:DescribeAddresses",          # Додано
          "ec2:DescribeInstances",          # Додано
          "ec2:CreateTags",                 # Додано              
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "iam:PassRole",
          "codebuild:StartBuild",
          "codebuild:BatchGetBuilds"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_codebuild_project" "lila_codebuild" {
  name          = "lila-codebuild"
  service_role  = aws_iam_role.codebuild_service_role.arn
  description   = "Project for Lila application build"

  source {
    type      = "GITHUB"
    location  = var.github_repo_url
    buildspec = file("${path.module}/buildspec.yml")
  }

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_MEDIUM"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
    environment_variable {
      name  = "MONGO_DOMAIN"
      value = var.mongo_domain
    }
    environment_variable {
      name  = "LILA_DOMAIN"
      value = var.lila_domain
    }
    environment_variable {
      name  = "REDIS_DOMAIN"
      value = var.redis_domain
    }
    environment_variable {
      name  = "DOCKER_USERNAME"
      value = var.docker_username
    }
    environment_variable {
      name  = "DOCKER_PASSWORD"
      value = var.docker_password
    }
    environment_variable {
      name  = "DB_HOST"
      value = var.docdb_endpoint
    }
    environment_variable {
      name  = "DB_USER"
      value = var.db_username
    }
    environment_variable {
      name  = "DB_PASSWORD"
      value = var.db_password
    }
    environment_variable {
      name  = "VERSION"
      value = var.app_version
    }
  }
  
  vpc_config {
    vpc_id             = var.vpc_id
    subnets            = var.private_subnet_ids
    security_group_ids = [var.docdb_security_group_id]      
  }

  cache {
    type     = "S3"
    location = var.s3_cache_bucket
  }
}
