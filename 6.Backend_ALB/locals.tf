locals {
    private_subnet_id = split(",", data.aws_ssm_parameter.private_subnet_id.value)
    vpc_id = data.aws_ssm_parameter.vpc.value
    app_alb_sg_id = data.aws_ssm_parameter.app_alb_sg_id.value
    # backend_target_group_arn = data.aws_ssm_parameter.backend_target_group.value
}