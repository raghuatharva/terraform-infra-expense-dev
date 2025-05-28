locals {
  mysql_sg              = data.aws_ssm_parameter.mysql_sg_id.value
  database_subnet_group = data.aws_ssm_parameter.database_subnet_group.value

}

