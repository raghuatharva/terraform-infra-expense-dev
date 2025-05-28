
data "aws_ami" "join_devops" {
  most_recent = true
  owners      = ["973714476881"]

  filter {
    name   = "name"
    values = ["RHEL-9-DevOps-Practice"] #this is case sensitive , so use it properly as is
  }
}

data "aws_ssm_parameter" "vpc_id" {
  name = "/${var.project}/${var.environment}/vpc_id"
}

data "aws_ssm_parameter" "private_subnet_id" {
  name = "/${var.project}/${var.environment}/private_subnet_ids"
}

data "aws_ssm_parameter" "backend_sg" {
  name = "/${var.project}/${var.environment}/backend_sg_id"
}

data "aws_ssm_parameter" "app_alb_listener" {
  name  = "/${var.project}/${var.environment}/app_alb_listener"
}