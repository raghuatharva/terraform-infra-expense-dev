module "app_alb" {
  source  = "terraform-aws-modules/alb/aws"

  name = "app-alb"
  internal = true
  vpc_id             = local.vpc_id
  subnets            = local.private_subnet_id
  security_groups    = [ local.app_alb_sg_id ]

  enable_deletion_protection = false
   create_security_group = false
  

}

############################### NOTE ###############################

# WE ARE NOT ASSOCIATING TARGET GROUP HERE BECAUSE WE HAVENT HAD BACKEND INSTANCES ..  we associate them in the next stage
# when we create (in order) backend instances --> target group ----> app ALB

resource "aws_lb_listener" "http" {
  load_balancer_arn = module.app_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "<h1>Hello, I am from Application ALB</h1>"
      status_code  = "200"
    }
  }

#  default_action {
#     type             = "forward"
#     target_group_arn = local.backend_target_group_arn
#   }
# you can simply add "forward requests to target group rather than doing all this .. 
    # fixed_response {
    #   content_type = "text/html"
    #   message_body = "<h1>Hi ... This is Rohan from backend application load balancer</h1>"
    #   status_code  = "200"
    # }
  }


module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 3.0"

  zone_name = var.zone_name

  records = [
    {
      name    = "*.app-dev"   #this dns name will become app-dev-rohanandlife.site
      type    = "A"
      alias   = {
        name    = module.app_alb.dns_name
        zone_id = module.app_alb.zone_id     # This belongs ALB internal hosted zone, not ours
      }
       allow_overwrite = true
    }
  ]
}
