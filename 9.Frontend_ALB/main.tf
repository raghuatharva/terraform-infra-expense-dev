module "web_alb" {
  source  = "terraform-aws-modules/alb/aws"

  name = "web-alb"
  internal = false
  vpc_id             = local.vpc_id
  subnets            = local.public_subnet_id
  security_groups    = [ local.web_alb_sg_id ]

 create_security_group = false
  enable_deletion_protection = false

}

############################### NOTE ###############################

# WE ARE NOT ASSOCIATING TARGET GROUP HERE BECAUSE WE HAVENT HAD BACKEND INSTANCES ..  we associate them in the next stage
# when we create (in order) backend instances --> target group ----> web ALB

resource "aws_lb_listener" "web_http" {
  load_balancer_arn = module.web_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
     type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>Hi ... This is Rohan from frontend weblication load balancer</h1>"
      status_code  = "200"
    }
  }
}

 
  # you can simply add "forward requests to target group rather than doing all this 
#   default_action {
#     type             = "forward"
#     target_group_arn = local.target_group_arn
#   }
# }
 
  


resource "aws_lb_listener" "web_https" {
  load_balancer_arn = module.web_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = local.certificate_arn

    default_action {
     type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>Hi ... This is Rohan from backend weblication load balancer</h1>"
      status_code  = "200"
    }

#  default_action {
#     type             = "forward"
#     target_group_arn = local.target_group_arn
#   }
 
  }
}

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 3.0"

  zone_name = var.zone_name

  records = [
    {
      name    = "web-dev"   #this dns name will become web-dev-rohanandlife.site
      type    = "A"
      alias   = {
        name    = module.web_alb.dns_name
        zone_id = module.web_alb.zone_id     # This belongs ALB internal hosted zone, not ours
      }
       allow_overwrite = true
    }
  ]
}
