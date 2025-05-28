locals {
  resource_name    = "${var.project}-${var.environment}-vpn"
  ami              = data.aws_ami.openvpn.id
  public_subnet_id = split(",", data.aws_ssm_parameter.public_subnet_id.value)[0] #since we want only list , which we made to stringlist by join fucntion
  vpn_sg      = data.aws_ssm_parameter.vpn_sg.value
  
}