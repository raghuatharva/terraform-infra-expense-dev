resource "aws_ssm_parameter" "frontend_target_group" {
  name  = "/${var.project}/${var.environment}/frontend_target_group"
  type  = "String"
  value = aws_lb_target_group.frontend.arn
}