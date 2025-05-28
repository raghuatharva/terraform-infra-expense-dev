resource "aws_ssm_parameter" "app_alb_listener" {
  # /expense/dev/mysql_sg_id
  name  = "/${var.project}/${var.environment}/app_alb_listener"
  type  = "String"
  value = aws_lb_listener.http.arn
}