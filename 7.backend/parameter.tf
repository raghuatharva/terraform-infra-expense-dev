resource "aws_ssm_parameter" "backend_target_group" {
  name  = "/${var.project}/${var.environment}/backend_target_group"
  type  = "String"
  value = aws_lb_target_group.backend.arn
}