terraform {
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

#############################
# IAM Roles for ECS Tasks
#############################

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

#############################
# Networking Resources
#############################

# Create a VPC
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.vpc_name
  }
}

# Create an Internet Gateway and attach it to the VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

# Create Subnet 1 within the VPC (in AZ1)
resource "aws_subnet" "this_1" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.subnet_cidr_1
  availability_zone = var.availability_zone_1

  tags = {
    Name = var.subnet_name_1
  }
}

# Create Subnet 2 within the VPC (in AZ2)
resource "aws_subnet" "this_2" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.subnet_cidr_2
  availability_zone = var.availability_zone_2

  tags = {
    Name = var.subnet_name_2
  }
}

# Create a Public Route Table with a default route to the Internet Gateway
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}

# Associate the Route Table with Subnet 1
resource "aws_route_table_association" "public_association_1" {
  subnet_id      = aws_subnet.this_1.id
  route_table_id = aws_route_table.public.id
}

# Associate the Route Table with Subnet 2
resource "aws_route_table_association" "public_association_2" {
  subnet_id      = aws_subnet.this_2.id
  route_table_id = aws_route_table.public.id
}

# Create a Security Group that allows all inbound and outbound traffic (for troubleshooting)
resource "aws_security_group" "ecs" {
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

  tags = {
    Name = var.sg_name
  }
}

#############################
# ECS Cluster
#############################

resource "aws_ecs_cluster" "this" {
  name = var.cluster_name
}

#############################
# ALB Resources for Backend
#############################

# Create an Application Load Balancer in our public subnets
resource "aws_lb" "backend_alb" {
  name               = "backend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs.id]
  subnets            = [aws_subnet.this_1.id, aws_subnet.this_2.id]

  tags = {
    Name = "backend-alb"
  }
}

# Create a Target Group for the backend service (using target_type = "ip")
resource "aws_lb_target_group" "backend_tg" {
  name        = "backend-tg"
  port        = var.backend_port  # 8000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.this.id
  target_type = "ip"   # Important for awsvpc mode

  health_check {
    path                = "/"  # Adjust if your backend has a specific health endpoint
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "backend-tg"
  }
}

# Create a Listener on the ALB on port 80 that forwards to the target group
resource "aws_lb_listener" "backend_listener" {
  load_balancer_arn = aws_lb.backend_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_tg.arn
  }
}

#############################
# ECS Task Definitions
#############################

# Backend Task Definition
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
      image        = "mfkimbell/aws-saas-template:backend-0204-0253PM",
      cpu          = var.cpu,
      memory       = var.memory,
      essential    = true,
      portMappings = [
        {
          containerPort = var.backend_port,
          hostPort      = var.backend_port,
          protocol      = "tcp"
        }
      ]
    }
  ])
}

# Frontend Task Definition
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
      image        = "mfkimbell/aws-saas-template:frontend-0204-0253PM",
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
          name  = "API_URL"
          value = "http://${aws_lb.backend_alb.dns_name}"
        }
      ]
    }
  ])
}

#############################
# ECS Services
#############################

# Backend Service (registered with the ALB target group)
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

# Frontend Service (unchanged; still accessed via its public IP)
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
}
