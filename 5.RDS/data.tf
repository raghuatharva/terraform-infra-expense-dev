data "aws_ssm_parameter" "mysql_sg_id" {
  name = "/${var.project}/${var.environment}/mysql_sg_id"
}

data "aws_ssm_parameter" "database_subnet_group" {
  name = "/${var.project}/${var.environment}/database_subnet_group"
}