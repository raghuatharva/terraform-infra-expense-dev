module "frontend" {
  source = "terraform-aws-modules/ec2-instance/aws"

  ami                    = local.ami
  instance_type          = "t2.micro"
  subnet_id              = local.public_subnet_id
  vpc_security_group_ids = [local.frontend_sg]
  name                   = "frontend-${local.resource_name}"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

#   Now to configure the instance we need to run remote exec and do some changes [like deploying code]
resource "null_resource" "frontend" {
  triggers = {                      # provision run only once during the first time of instance creation
    instance_id = module.frontend.id # to trigger everytime when frontend instance id Changes ,
  }                                 # we use triggers where provisioners are there 


  connection {

    host     = module.frontend.public_ip
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    # public_key = file("~/.ssh/id_rsa") # password authentification will not work in aws , only works with joindevops ami
  }

  provisioner "file" {
    source      = "expense.sh"      #in local machine
    destination = "/tmp/expense.sh" #in the actual server 
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/expense.sh",
      "sudo bash /tmp/expense.sh frontend dev" #argument1 = frontend , argument2 = dev
    ]
  }

}

## stopping the instance since we cant take AMI of a running instance
resource "aws_ec2_instance_state" "frontend" {
  instance_id = module.frontend.id
  state       = "stopped"
  depends_on  = [null_resource.frontend]
}

resource "aws_ami_from_instance" "frontend" {
  name               = "frontend-expense-dev"
  source_instance_id = module.frontend.id
  depends_on         = [aws_ec2_instance_state.frontend]
}

resource "aws_launch_template" "frontend" {
  name                                 = "frontend-launch-template"
  image_id                             = aws_ami_from_instance.frontend.id
  instance_type                        = "t2.micro"
  instance_initiated_shutdown_behavior = "terminate"

  # You have an ASG running web servers. If a server shuts down due to an 
  # internal failure (like out-of-memory), it should be terminated(not stopped) and replaced automatically.

  update_default_version = true #every new config will update launch template. so to get latest template use true
  vpc_security_group_ids = [local.frontend_sg]
}





# This instance only used to configure and get ami , after that this instance wont serve as server ,so deleting
resource "null_resource" "frontend_delete" {

  triggers = { # provisioner is there so trigger is required 
    instance_id = module.frontend.id
  }

  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids ${module.frontend.id} --region us-east-1"
  }

  depends_on = [aws_ami_from_instance.frontend]
}


resource "aws_lb_target_group" "frontend" {
  name     = "frontend"
  port     = 80
  protocol = "HTTP"
  vpc_id   = local.vpc_id
  
  health_check {
    healthy_threshold = 4
   unhealthy_threshold = 4
    matcher = "200-299"
    interval = 10 
    protocol = "HTTP"
    port     = 80   # health check port , this port and target group port can be different 
    #                   but default value is target group port 
    path     = "/health"
    timeout = 5 #waiting time before deciding unhealthy
  }
}


resource "aws_lb_listener_rule" "target_group_routing" {
  listener_arn = local.web_alb_listener_https
  priority     = 1 # lesser the number , the priority for this rule increases

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }

  condition {
    host_header {
      values = ["web-dev.${var.zone_name}"] #this means if someone access with this url means , it will  
      #                                             access target group instances just we are specifying with dns ,thats all 
      #                                            like amazon.com/cart , amazon.com/login --> diff. services need diff. domain
      #                                      here we are specifying target group domain = frontend.web-dev.rohanandlife.site , thats all
    }
  }
}

#AUTOSCALING

resource "aws_autoscaling_group" "frontend" {
  name                = "frontend-autoscaling-group"
  max_size            = 4
  min_size            = 1
  desired_capacity    = 1
  vpc_zone_identifier = [local.public_subnet_id] 
  target_group_arns = [aws_lb_target_group.frontend.arn]

  launch_template {
    id      = aws_launch_template.frontend.id
    version = "$Latest"
  }

  # Rolling update configuration
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50   #  50% will remain healthy; asg will make sure about this at any cost
    }
    triggers = ["launch_template"]
  }

  tag {
    key                 = "Name"
    value               = "autoscaling-frontend"
    propagate_at_launch = true
  }

   # If instances are not healthy with in 15min, autoscaling will delete that instance
  timeouts {
    delete = "15m"
  }
}

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "cpu-scale-out"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.frontend.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 70.0
  }
}







    