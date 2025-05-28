
resource "aws_ssm_parameter" "web_alb_sg_id" {
  # /expense/dev/mysql_sg_id
  name  = "/${var.project}/${var.environment}/web_alb_sg_id"
  type  = "String"
  value = module.web_alb_sg.id
}

resource "aws_ssm_parameter" "frontend_sg_id" {
  # /expense/dev/mysql_sg_id
  name  = "/${var.project}/${var.environment}/frontend_sg_id"
  type  = "String"
  value = module.frontend_sg.id
}


resource "aws_ssm_parameter" "backend_sg_id" {
  # /expense/dev/mysql_sg_id
  name  = "/${var.project}/${var.environment}/backend_sg_id"
  type  = "String"
  value = module.backend_sg.id
}

resource "aws_ssm_parameter" "app_alb_sg_id" {
  # /expense/dev/mysql_sg_id
  name  = "/${var.project}/${var.environment}/app_alb_sg_id"
  type  = "String"
  value = module.app_alb_sg.id
}

resource "aws_ssm_parameter" "mysql_sg_id" {
  # /expense/dev/mysql_sg_id
  name  = "/${var.project}/${var.environment}/mysql_sg_id"
  type  = "String"
  value = module.mysql_sg.id
}

resource "aws_ssm_parameter" "vpn_sg_id" {
  # /expense/dev/mysql_sg_id
  name  = "/${var.project}/${var.environment}/vpn_sg_id"
  type  = "String"
  value = module.vpn_sg.id
}

resource "aws_ssm_parameter" "bastion_sg_id" {
  # /expense/dev/mysql_sg_id
  name  = "/${var.project}/${var.environment}/bastion_sg_id"
  type  = "String"
  value = module.bastion_sg.id
}

