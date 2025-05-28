data "aws_ssm_parameter" "vpc" {
  name = "/${var.project}/${var.environment}/vpc_id"
}

data "aws_ssm_parameter" "app_alb_sg_id" {
  name = "/${var.project}/${var.environment}/app_alb_sg_id"
}

data "aws_ssm_parameter" "private_subnet_id" {
  name = "/${var.project}/${var.environment}/private_subnet_ids"
}

# data "aws_ssm_parameter" "backend_target_group" {
#   name = "/${var.project}/${var.environment}/backend_target_group"
# }