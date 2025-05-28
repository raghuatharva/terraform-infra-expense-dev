locals {
  resource_name     = "${var.project}-${var.environment}"
  vpc_id            = data.aws_ssm_parameter.vpc_id.value
  ami               = data.aws_ami.join_devops.id
  public_subnet_id  = split(",", data.aws_ssm_parameter.public_subnet_id.value)[0]
  web_alb_listener_http  = data.aws_ssm_parameter.web_alb_listener_http.value
  web_alb_listener_https =  data.aws_ssm_parameter.web_alb_listener_https.value
  frontend_sg       = data.aws_ssm_parameter.frontend_sg.value
}

