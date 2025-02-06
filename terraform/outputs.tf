output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.igw.id
}

output "subnet_id_1" {
  description = "The ID of Subnet 1"
  value       = aws_subnet.this_1.id
}

output "subnet_id_2" {
  description = "The ID of Subnet 2"
  value       = aws_subnet.this_2.id
}

output "route_table_id" {
  description = "The ID of the Public Route Table"
  value       = aws_route_table.public.id
}

output "security_group_id" {
  description = "The ID of the Security Group"
  value       = aws_security_group.ecs.id
}

output "ecs_cluster_id" {
  description = "The ECS Cluster ID"
  value       = aws_ecs_cluster.this.id
}

output "ecs_cluster_name" {
  description = "The ECS Cluster Name"
  value       = aws_ecs_cluster.this.name
}

output "ecs_task_execution_role_arn" {
  description = "ARN of the ECS Task Execution Role"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "ecs_task_role_arn" {
  description = "ARN of the ECS Task Role"
  value       = aws_iam_role.ecs_task_role.arn
}

output "backend_task_definition_arn" {
  description = "ARN of the Backend Task Definition"
  value       = aws_ecs_task_definition.backend.arn
}

output "frontend_task_definition_arn" {
  description = "ARN of the Frontend Task Definition"
  value       = aws_ecs_task_definition.frontend.arn
}

output "backend_service_name" {
  description = "Name of the Backend ECS Service"
  value       = aws_ecs_service.backend.name
}

output "frontend_service_name" {
  description = "Name of the Frontend ECS Service"
  value       = aws_ecs_service.frontend.name
}

output "backend_alb_dns" {
  description = "The DNS name of the backend ALB"
  value       = aws_lb.backend_alb.dns_name
}

output "frontend_alb_dns" {
  description = "The DNS name of the frontend ALB"
  value       = aws_lb.frontend_alb.dns_name
}

output "backend_database_url" {
  description = "The connection string for the backend database"
  value       = "postgresql://${var.db_username}:${var.db_password}@${aws_db_instance.backend_db.address}:${aws_db_instance.backend_db.port}/${var.db_name}"
}

