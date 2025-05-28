# ssh into vpn instance ---> ssh -i "~/.ssh/openvpn_rsa" openvpnas@34.207.130.5 
# give yes to all the questions asked
# it gives the below list  as it is 

# Initial Configuration Complete!

# You can now continue configuring OpenVPN Access Server by
# directing your Web browser to this URL:

# https://34.229.38.81:943/admin

# During normal operation, OpenVPN AS can be accessed via these URLs:
# Admin  UI: https://34.229.38.81:943/admin
# Client UI: https://34.229.38.81:943/
# To login please use the "openvpn" account with "CsLqnZQ3cQjt" password. 

# go to the admin url and login with the above credentials
# change dns server to google dns server ie. 8.8.8.8 and 8.8.4.4

# open the openvpn app and login with the above credentials--- use Client UI: https://34.229.38.81:943/ and
# establish a connection

resource "aws_key_pair" "openvpn" {
  key_name   = "openvpn_rsa"        # this name should match the downloaded private file through ssh-keygen
  public_key = file("/Users/apple/.ssh/openvpn_rsa.pub") #just doing ssh-keygen is enough , type of key doesnt matter
}

module "openvpn" {
  source = "terraform-aws-modules/ec2-instance/aws"

  ami                    = local.ami
  key_name               =  aws_key_pair.openvpn.key_name
  instance_type          = "t2.micro"
 # subnet_id              = local.public_subnet_id
  subnet_id   = local.public_subnet_id
 # vpc_security_group_ids = [local.vpn_sg] #always a list
 vpc_security_group_ids = [local.vpn_sg]
  name                   = local.resource_name

  tags = { #here tags is not an argument , its a variable 
    Terraform   = "true"
    Environment = "dev"
  }
}