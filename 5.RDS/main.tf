module "db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "rds-expense-dev"

  engine            = "mysql"
  engine_version    = "5.7"
  instance_class    = "db.t3.micro"
  allocated_storage = 5

  db_name  = "transactions" #database name inside rds 
  username = "root"
  port     = "3306"
  manage_master_user_password = false
  password = "ExpenseApp1"

 

  vpc_security_group_ids = [local.mysql_sg]

    #  subnet ids---> no need to mention subnet ids since we use subnet groups .. subnet group
  # already has subnet ids

  db_subnet_group_name = local.database_subnet_group
 
  # DB parameter group
  family = "mysql5.7"

  # DB option group
  major_engine_version = "5.7"

  # Database Deletion Protection
  # deletion_protection = true
  skip_final_snapshot = true 


  # maintenance_window = "Mon:00:00-Mon:03:00"
  # backup_window      = "03:00-06:00"

  # Enhanced Monitoring - see example for details on how to create the role
  # by yourself, in case you don't want to create it automatically

  # monitoring_interval    = "30"
  # monitoring_role_name   = "MyRDSMonitoringRole"
  # create_monitoring_role = true

  tags = {
    Project       = "expense"
    Environment = "dev"
  }


### character_set_client and character_set_server:

    # Setting both to utf8mb4 ensures that the database can properly handle 
    #  multi-byte characters(like emojis or certain non-Latin scripts).
    # This is important for modern applications where data consistency and character encoding are critical.
  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]

    #MariaDB block :  Enables the MariaDB Audit Plugin, which helps log and track database activities.


  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"

      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        },
        {
          name  = "SERVER_AUDIT_FILE_ROTATIONS"
          value = "37"
        },
      ]
    },
  ]
}

###### ROUTE 53 RECORD ###############

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 3.0"

  zone_name = var.zone_name

  records = [
    {
      name    = "mysql-dev"
      type    = "CNAME"
      ttl   = 50
      records    = [module.db.db_instance_address] 
      allow_overwrite = true
      }
    
  ]
}

