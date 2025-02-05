variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# Networking Variables
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "Name for the VPC"
  type        = string
  default     = "saas-vpc"
}

variable "subnet_cidr_1" {
  description = "CIDR block for Subnet 1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "availability_zone_1" {
  description = "Availability zone for Subnet 1"
  type        = string
  default     = "us-east-1a"
}

variable "subnet_name_1" {
  description = "Name for Subnet 1"
  type        = string
  default     = "saas-subnet-1"
}

variable "subnet_cidr_2" {
  description = "CIDR block for Subnet 2"
  type        = string
  default     = "10.0.2.0/24"
}

variable "availability_zone_2" {
  description = "Availability zone for Subnet 2"
  type        = string
  default     = "us-east-1b"
}

variable "subnet_name_2" {
  description = "Name for Subnet 2"
  type        = string
  default     = "saas-subnet-2"
}

variable "sg_name" {
  description = "Security group name"
  type        = string
  default     = "ecs-sg"
}

# ECS Cluster and Service Variables
variable "cluster_name" {
  description = "ECS cluster name"
  type        = string
  default     = "saas-cluster"
}

variable "backend_service_name" {
  description = "Backend ECS service name"
  type        = string
  default     = "saas-backend"
}

variable "frontend_service_name" {
  description = "Frontend ECS service name"
  type        = string
  default     = "saas-frontend"
}

variable "backend_task_family" {
  description = "Task family for the backend"
  type        = string
  default     = "backend-task"
}

variable "frontend_task_family" {
  description = "Task family for the frontend"
  type        = string
  default     = "frontend-task"
}

variable "cpu" {
  description = "CPU units for ECS tasks"
  type        = number
  default     = 256
}

variable "memory" {
  description = "Memory for ECS tasks"
  type        = number
  default     = 512
}

variable "backend_port" {
  description = "Backend container port"
  type        = number
  default     = 8000
}

variable "frontend_port" {
  description = "Frontend container port"
  type        = number
  default     = 3000
}
