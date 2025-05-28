locals {
  resource_name = "${var.project}-${var.environment}"
  vpc_id        = data.aws_ssm_parameter.vpc_id.value
  ami           = data.aws_ami.join_devops.id
  private_subnet_id = split(",", data.aws_ssm_parameter.private_subnet_id.value)[0]
  #out of2 subnets , 1st subnet is used for instance creation ; if we dont specify aws automatically 
  # pick any ONE out of 2 for consistancy , specify which subnet zero index ---> 1st private subnet
  app_alb_listener = data.aws_ssm_parameter.app_alb_listener.value
  backend_sg = data.aws_ssm_parameter.backend_sg.value


}