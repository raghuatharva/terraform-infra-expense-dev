# security groups required for the project

module "backend_sg" {
  source       = "git::https://github.com/raghuatharva/terraform-aws-security-group.git?ref=main"
  vpc_id       = local.vpc_id
  sg_name      = "backend"
  project_name = var.project
  environment  = var.environment

}

module "frontend_sg" {
  source       = "git::https://github.com/raghuatharva/terraform-aws-security-group.git?ref=main"
  vpc_id       = local.vpc_id
  sg_name      = "frontend"
  project_name = var.project
  environment  = var.environment

}

module "bastion_sg" {
  source       = "git::https://github.com/raghuatharva/terraform-aws-security-group.git?ref=main"
  vpc_id       = local.vpc_id
  sg_name      = "bastion"
  project_name = var.project
  environment  = var.environment

}


module "mysql_sg" {
  source       = "git::https://github.com/raghuatharva/terraform-aws-security-group.git?ref=main"
  vpc_id       = local.vpc_id
  sg_name      = "rds"
  project_name = var.project
  environment  = var.environment

}

module "app_alb_sg" {
  source       = "git::https://github.com/raghuatharva/terraform-aws-security-group.git?ref=main"
  vpc_id       = local.vpc_id
  sg_name      = "app-alb"
  project_name = var.project
  environment  = var.environment

}

module "vpn_sg" {
  source       = "git::https://github.com/raghuatharva/terraform-aws-security-group.git?ref=main"
  vpc_id       = local.vpc_id
  sg_name      = "openvpn"
  project_name = var.project
  environment  = var.environment

}

module "web_alb_sg" {
  source       = "git::https://github.com/raghuatharva/terraform-aws-security-group.git?ref=main"
  vpc_id       = local.vpc_id
  sg_name      = "web-alb"
  project_name = var.project
  environment  = var.environment

}

#------> most important rules for traffic flow for user to access the application <------#


#ingress rules [FROM PUBLIC TO FRONTEND ALB http]
resource "aws_security_group_rule" "public_to_web_alb_80" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.web_alb_sg.id
}

#ingress rules [FROM PUBLIC TO FRONTEND ALB https]
resource "aws_security_group_rule" "public_to_web_alb_443" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
 security_group_id = module.web_alb_sg.id
}


#ingress rules [FROM FRONTEND ALB to FRONTEND]
resource "aws_security_group_rule" "frontend_alb_to_frontend" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = module.frontend_sg.id
  source_security_group_id = module.web_alb_sg.id
}

#ingress rules [FROM FRONTEND TO BACKEND ALB]
resource "aws_security_group_rule" "frontend_to_backend_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = module.app_alb_sg.id
  source_security_group_id = module.frontend_sg.id
}

#ingress rules [FROM BACKEND ALB TO BACKEND]
resource "aws_security_group_rule" "backend_alb_to_backend" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = module.backend_sg.id
  source_security_group_id = module.app_alb_sg.id
}

#ingress rules [FROM BACKEND TO MYSQL]
resource "aws_security_group_rule" "backend_to_mysql" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = module.mysql_sg.id
  source_security_group_id = module.backend_sg.id
}



#----> BASTION AS SOURCE <----#

#ingress rules [FROM BASTION TO WEB Load Balancer]
resource "aws_security_group_rule" "bastion_to_web_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = module.web_alb_sg.id
  source_security_group_id = module.bastion_sg.id
}

#ingress rules [FROM BASTION TO FRONTEND port 80]
resource "aws_security_group_rule" "bastion_to_frontend_port80" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = module.frontend_sg.id
  source_security_group_id = module.bastion_sg.id
}
#ingress rules [FROM BASTION TO frontend port 22]
resource "aws_security_group_rule" "bastion_to_frontend_port22" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = module.frontend_sg.id
  source_security_group_id = module.bastion_sg.id
}

#ingress rules [FROM BASTION TO Application Load Balancer]
resource "aws_security_group_rule" "bastion_to_app_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = module.app_alb_sg.id
  source_security_group_id = module.bastion_sg.id
}

#ingress rules [FROM BASTION TO Backend port 8080]
resource "aws_security_group_rule" "bastion_to_backend_port8080" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = module.backend_sg.id
  source_security_group_id = module.bastion_sg.id
}

#ingress rules [FROM BASTION TO backend port 22]
resource "aws_security_group_rule" "bastion_to_backend_port22" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = module.backend_sg.id
  source_security_group_id = module.bastion_sg.id
}

#ingress rules [FROM BASTION TO RDS]
resource "aws_security_group_rule" "bastion_to_rds" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = module.mysql_sg.id
  source_security_group_id = module.bastion_sg.id
}

# ----> TO LOGIN TO BASTION FROM ANY IP <----#
resource "aws_security_group_rule" "bastion_ingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = module.bastion_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}



## ----> TO LOGIN TO VPN INSTANCE FROM ANY IP <----#
#ingress rules [FROM public to VPN ]
resource "aws_security_group_rule" "vpn_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn_sg.id
}

#ingress rules [FROM public to VPN ]
resource "aws_security_group_rule" "vpn_pub" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn_sg.id
}

#ingress rules [FROM public to VPN ]
resource "aws_security_group_rule" "vpn_publ" {
  type              = "ingress"
  from_port         = 1194
  to_port           = 1194
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn_sg.id
}

#ingress rules [FROM public to VPN ]
resource "aws_security_group_rule" "vpn_publi" {
  type              = "ingress"
  from_port         = 943
  to_port           = 943
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn_sg.id
}

#ingress rules [FROM VPN To frontend port 22 ]
resource "aws_security_group_rule" "vpn_to_frontend_port22" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = module.frontend_sg.id
  source_security_group_id = module.vpn_sg.id
}

#ingress rules [FROM VPN To frontend port 80 ] ---> not required ;why? you can access through browser itself

#ingress rules [FROM VPN To BACKEND ALB  ]
resource "aws_security_group_rule" "vpn_to_backend_alb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = module.app_alb_sg.id
  source_security_group_id = module.vpn_sg.id
}

#ingress rules [FROM VPN To BACKEND ;port 8080]
resource "aws_security_group_rule" "vpn_to_backend" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  security_group_id        = module.backend_sg.id
  source_security_group_id = module.vpn_sg.id
}

#ingress rules [FROM VPN To BACKEND ;port 22]
resource "aws_security_group_rule" "vpn_to_backend_port22" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  security_group_id        = module.backend_sg.id
  source_security_group_id = module.vpn_sg.id
}

#ingress rules [FROM VPN To RDS ]
resource "aws_security_group_rule" "vpn_to_rds" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = module.mysql_sg.id
  source_security_group_id = module.vpn_sg.id
}



# -------------------------------------





