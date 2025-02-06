##############################################
# Terraform and Provider Config
##############################################
terraform {
  cloud { 
    
    organization = "mfkimbell" 

    workspaces { 
      name = "aws-saas-template" 
    } 
  } 
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}


provider "aws" {
  region = var.aws_region
}

# Retrieve AWS Account ID (for constructing secret ARNs)
data "aws_caller_identity" "current" {}

##############################################
# IAM Roles for ECS Tasks
##############################################
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Inline Policy to allow retrieval of secrets from Secrets Manager
data "aws_iam_policy_document" "ecs_task_execution_inline_policy" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = [
      "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:*"
    ]
  }
}

resource "aws_iam_policy" "ecs_task_execution_inline_policy" {
  name        = "ecsTaskExecutionInlinePolicy"
  description = "Allow ECS tasks to retrieve secrets from Secrets Manager"
  policy      = data.aws_iam_policy_document.ecs_task_execution_inline_policy.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_inline_attach" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_task_execution_inline_policy.arn
}

resource "aws_iam_role" "ecs_task_role" {
  name = "ecsTaskRole"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ecs-tasks.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

##############################################
# Networking Resources
##############################################
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  tags = { Name = var.vpc_name }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags = { Name = "${var.vpc_name}-igw" }
}

resource "aws_subnet" "this_1" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.subnet_cidr_1
  availability_zone = var.availability_zone_1
  tags = { Name = var.subnet_name_1 }
}

resource "aws_subnet" "this_2" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.subnet_cidr_2
  availability_zone = var.availability_zone_2
  tags = { Name = var.subnet_name_2 }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "${var.vpc_name}-public-rt" }
}

resource "aws_route_table_association" "public_association_1" {
  subnet_id      = aws_subnet.this_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_association_2" {
  subnet_id      = aws_subnet.this_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "ecs" {
  name   = var.sg_name
  vpc_id = aws_vpc.this.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = var.sg_name }
}

##############################################
# ECS Cluster
##############################################
resource "aws_ecs_cluster" "this" {
  name = var.cluster_name
}

##############################################
# ALB Resources for Backend
##############################################
resource "aws_lb" "backend_alb" {
  name               = "backend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs.id]
  subnets            = [aws_subnet.this_1.id, aws_subnet.this_2.id]
  tags = { Name = "backend-alb" }
}

resource "aws_lb_target_group" "backend_tg" {
  name        = "backend-tg"
  port        = var.backend_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.this.id
  target_type = "ip"
  health_check {
    path                = "/"  
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  tags = { Name = "backend-tg" }
}

resource "aws_lb_listener" "backend_listener" {
  load_balancer_arn = aws_lb.backend_alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}

##############################################
# ALB Resources for Frontend
##############################################
resource "aws_lb" "frontend_alb" {
  name               = "frontend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs.id]
  subnets            = [aws_subnet.this_1.id, aws_subnet.this_2.id]
  tags = { Name = "frontend-alb" }
}

resource "aws_lb_target_group" "frontend_tg" {
  name        = "frontend-tg"
  port        = var.frontend_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.this.id
  target_type = "ip"
  health_check {
    path                = "/"  
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  tags = { Name = "frontend-tg" }
}

resource "aws_lb_listener" "frontend_listener" {
  load_balancer_arn = aws_lb.frontend_alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}

##############################################
# CloudWatch Log Groups for ECS
##############################################
resource "aws_cloudwatch_log_group" "ecs_backend" {
  name              = "/ecs/${var.backend_service_name}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "ecs_frontend" {
  name              = "/ecs/${var.frontend_service_name}"
  retention_in_days = 7
}

##############################################
# RDS & Secrets for Database Connection
##############################################

# DB Subnet Group
resource "aws_db_subnet_group" "db_subnets" {
  name       = "saas-backend-db-subnet-group"
  subnet_ids = [aws_subnet.this_1.id, aws_subnet.this_2.id]
  tags = { Name = "saas-backend-db-subnet-group" }
}

# DB Security Group for RDS
resource "aws_security_group" "db_sg" {
  name   = "db-sg"
  vpc_id = aws_vpc.this.id
  ingress {
    description      = "Allow ECS tasks access on PostgreSQL port"
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    security_groups  = [aws_security_group.ecs.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "db-sg" }
}

# RDS Instance for PostgreSQL
resource "aws_db_instance" "backend_db" {
  identifier              = "saas-backend-db"
  engine                  = "postgres"
  instance_class          = "db.t3.micro"
  allocated_storage       = 5
  storage_type            = "gp2"
  username                = var.db_username
  password                = var.db_password
  db_name                 = var.db_name
  publicly_accessible     = false
  skip_final_snapshot     = true
  vpc_security_group_ids  = [aws_security_group.db_sg.id]
  db_subnet_group_name    = aws_db_subnet_group.db_subnets.name
  tags = { Name = "saas-backend-db" }
}

locals {
  rds_connection_string = "postgresql://${var.db_username}:${var.db_password}@${aws_db_instance.backend_db.address}:${aws_db_instance.backend_db.port}/${var.db_name}"
}

resource "aws_secretsmanager_secret" "db_connection_secret" {
  name = "DB_URL_${formatdate("MMDD-hhmmAA", timestamp())}"
}


resource "aws_secretsmanager_secret_version" "db_connection_secret_version" {
  secret_id     = aws_secretsmanager_secret.db_connection_secret.id
  secret_string = local.rds_connection_string
}

##############################################
# ECS Task Definitions
##############################################

# Backend Task Definition with Secrets from Secrets Manager
resource "aws_ecs_task_definition" "backend" {
  family                   = var.backend_task_family
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name         = var.backend_service_name,
      image        = var.backend_image,
      cpu          = var.cpu,
      memory       = var.memory,
      essential    = true,
      portMappings = [
        {
          containerPort = var.backend_port,
          hostPort      = var.backend_port,
          protocol      = "tcp"
        }
      ],
      # environment = [
      #   {
      #     name  = "DB_URL",
      #     value = "postgresql://${var.db_username}:${var.db_password}@${aws_db_instance.backend_db.address}:${aws_db_instance.backend_db.port}/${var.db_name}"
      #   }
      # ],
      secrets = [
        {
          name      = "DB_URL",
          valueFrom = aws_secretsmanager_secret.db_connection_secret.arn
        },
        {
          name      = "JWT_SECRET",
          valueFrom = "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:backend/JWT_SECRET"
        },
        {
          name      = "APP_MODE",
          valueFrom = "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:backend/APP_MODE"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-region        = var.aws_region,
          awslogs-group         = aws_cloudwatch_log_group.ecs_backend.name,
          awslogs-stream-prefix = "backend"
        }
      },
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:8000/health || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 15
      }
    }
  ])
}

# Frontend Task Definition with Secrets from Secrets Manager and Health Check
resource "aws_ecs_task_definition" "frontend" {
  family                   = var.frontend_task_family
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name         = var.frontend_service_name,
      image        = var.frontend_image,
      cpu          = var.cpu,
      memory       = var.memory,
      essential    = true,
      portMappings = [
        {
          containerPort = var.frontend_port,
          hostPort      = var.frontend_port,
          protocol      = "tcp"
        }
      ],
      environment = [
        {
          name  = "API_URL",
          value = "http://${aws_lb.backend_alb.dns_name}"
        },
        {
          name  = "NEXTAUTH_URL"
          value = "http://${aws_lb.frontend_alb.dns_name}" # Points to your frontend ALB
        }
      ],
      secrets = [
        {
          name      = "JWT_SECRET",
          valueFrom = "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:frontend/JWT_SECRET"
        },
        {
          name      = "NEXTAUTH_SECRET",
          valueFrom = "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:frontend/NEXTAUTH_SECRET"
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-region        = var.aws_region,
          awslogs-group         = aws_cloudwatch_log_group.ecs_frontend.name,
          awslogs-stream-prefix = "frontend"
        }
      },
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:3000/ || exit 1"]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 15
      }
    }
  ])
}

##############################################
# ECS Services
##############################################

# Backend Service (with ALB)
resource "aws_ecs_service" "backend" {
  name            = var.backend_service_name
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.backend.arn
  launch_type     = "FARGATE"
  desired_count   = 1
  network_configuration {
    subnets         = [aws_subnet.this_1.id, aws_subnet.this_2.id]
    security_groups = [aws_security_group.ecs.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.backend_tg.arn
    container_name   = var.backend_service_name
    container_port   = var.backend_port
  }
}

# Frontend Service (with ALB for stable endpoint)
resource "aws_ecs_service" "frontend" {
  name            = var.frontend_service_name
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.frontend.arn
  launch_type     = "FARGATE"
  desired_count   = 1
  network_configuration {
    subnets         = [aws_subnet.this_1.id, aws_subnet.this_2.id]
    security_groups = [aws_security_group.ecs.id]
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.frontend_tg.arn
    container_name   = var.frontend_service_name
    container_port   = var.frontend_port
  }
}
