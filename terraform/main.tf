module "networking" {
  source               = "./networking"
  vpc_cidr             = var.vpc_cidr
  vpc_name             = var.vpc_name
  ap_availability_zone = var.ap_availability_zone
  cidr_public_subnet   = var.cidr_public_subnet
  cidr_private_subnet  = var.cidr_private_subnet
}


module "security_group" {
  source                     = "./security-groups"
  ec2_sg_name                = "SG for EC2 to enable SSH(22), HTTPS(443) and HTTP(80)"
  vpc_id                     = module.networking.aws-vpc-id
  ec2_jenkins_sg_name        = "Allow port 8080 for jenkins"
  ec2_sg_name_for_python_api = "Allow port 5000 for python api"
  public_subnet_cidr_block   = tolist(module.networking.public_subnet_cidr_block) #var.cidr_public_subnet
}

module "ec2" {
  source                     = "./ec2"
  ami_id                     = var.ec2_ami_id
  instance_type              = "t2.micro"
  tag_name                   = "Ubuntu Linux EC2"
  public_key                 = var.public_key
  subnet_id                  = tolist(module.networking.aws_vpc_public_subnets)[0]
  sg_enable_ssh_https        = module.security_group.sg_ec2_sg_ssh_http_id
  ec2_sg_name_for_python_api = module.security_group.sg_ec2_for_python_api
  enable_public_ip_address   = true
  user_data_install_apache   = templatefile("./ec2/ec2_install.sh", {})
}

module "jenkins" {
  source                    = "./jenkins"
  ami_id                    = var.ec2_ami_id
  instance_type             = "t2.medium"
  tag_name                  = "Jenkins:Ubuntu Linux EC2"
  public_key                = var.public_key
  subnet_id                 = tolist(module.networking.aws_vpc_public_subnets)[1]
  sg_for_jenkins            = [module.security_group.sg_ec2_sg_ssh_http_id, module.security_group.sg_ec2_jenkins_port_8080]
  enable_public_ip_address  = true
  user_data_install_jenkins = templatefile("./jenkins/jenkins-installer.sh", {})
}


module "lb_target_group" {
  source                   = "./load-balancer-target-group"
  lb_target_group_name     = "lb-target-group" # "dev-proj-1-lb-target-group"
  lb_target_group_port     = 5000                      #8080
  lb_target_group_protocol = "HTTP"
  vpc_id                   = module.networking.aws-vpc-id
  ec2_instance_id          = module.ec2.ec2_instance_ip
  # ec2_instance_id          = module.jenkins.jenkins_ec2_instance_ip
  # ec2_instance_id          = module.ec2.dev_proj_1_ec2_instance_id
}


module "alb" {
  source              = "./load-balancer"
  lb_name             = "aws-restapi-1-alb"
  is_external         = false
  lb_type             = "application"
  sg_enable_ssh_https = module.security_group.sg_ec2_sg_ssh_http_id
  subnet_ids          = tolist(module.networking.aws_vpc_public_subnets)
  tag_name            = "aws-restapi-tag-1-alb"
  lb_target_group_arn = module.lb_target_group.aws_restapi_lb_target_group_arn
  ec2_instance_id     = module.jenkins.jenkins_ec2_instance_ip
  # ec2_instance_id         = module.ec2.dev_proj_1_ec2_instance_id
  lb_listner_port           = 80 # 5000
  lb_listner_protocol       = "HTTP"
  lb_listner_default_action = "forward"
  # lb_https_listner_port     = 443
  # lb_https_listner_protocol = "HTTPS"
  # dev_proj_1_acm_arn        = module.aws_ceritification_manager.dev_proj_1_acm_arn
  lb_target_group_attachment_port = 8080 #5000
}

module "rds_db_instance" {
  source               = "./rds"
  db_subnet_group_name = "db_private_subnet_group"
  subnet_groups       = tolist(module.networking.aws_vpc_private_subnets)
  rds_mysql_sg_id     = module.security_group.rds_mysql_sg_id
  mysql_db_identifier = "mydb"
  mysql_username      = "DB_USER"
  mysql_password      = "DB_PASSWORD"
  mysql_dbname        = "mysqldb"
}


# module "hosted_zone" {
#   source          = "./hosted-zone"
#   domain_name     = "jenkins.jhooq.org"
#   aws_lb_dns_name = module.alb.aws_lb_dns_name
#   aws_lb_zone_id  = module.alb.aws_lb_zone_id
# }


# module "aws_ceritification_manager" {
#   source         = "./certificate-manager"
#   domain_name    = "jenkins.jhooq.org"
#   hosted_zone_id = module.hosted_zone.hosted_zone_id
# }
