###Variables##
variable "allocated_storage" {}
variable "max_allocated_storage" {}
variable "storage_type" {}
variable "engine" {}
variable "engine_version" {}
variable "instance_class" {}
// variable "iops" {}                   // define iops when storage type is io1
variable "db_name" {}
variable "db_username" {}
variable "db_pass" {}
variable "db_port" {}
variable "db_encrypted" {}
// variable "db_parameter_group" {}
variable "parameter_group_name" {}
variable "deletion_protection" {}
variable "tag_owner" {}
variable "tag_environment" {}
variable "tag_role" {}
variable "tag_creater" {}
variable "tag_creation_date" {}
variable "tag_name" {}
##---------------------------------------
variable "maintenance_window" {}
variable "backup_window" {}
variable "backup_retention_period" {}
variable "allow_major_version_upgrade" {}
variable "apply_immediately" {}
variable "auto_minor_version_upgrade" {}
variable "monitoring_interval" {}
variable "monitoring_role_arn" {}
// variable "create_monitoring_role" {}
variable "final_snapshot_identifier"  {}
variable "copy_tags_to_snapshot" {}
variable "sg_ids" {}
// variable "allowed_cidr_blocks" {}
variable "multi_availability_zone" {}   // this is for mutli-az
// variable "availability_zone" {}         // this is for single az
variable "skip_final_snapshot" {}
variable "cloudwatch_logs_exports" {}
variable "subnet_ids" {}
variable "subnet_group_name" {}
variable "database_identifier" {}



##db_parameters########
// variable "para1" {}
// variable "value1" {}
// variable "para2" {}
// variable "value2" {}


resource "aws_db_subnet_group" "non-default_vpc" {
  name                                 = var.subnet_group_name
  subnet_ids                           = var.subnet_ids                   // the subnet's where our db can be accessed from. 

  tags = {
    Name = "My DB subnet group"
  }
}



resource "aws_db_instance" "postgres-db" {
  
  identifier                            = var.database_identifier
  allocated_storage                     = var.allocated_storage       // minimum is 20gb
  max_allocated_storage                 = var.max_allocated_storage     // setting this allows storage autoscaling 
  storage_type                          = var.storage_type     // gp2 and prov provisioned iops
  engine                                = var.engine
  engine_version                        = var.engine_version
  instance_class                        = var.instance_class
  // iops                                  = var.iops                      // for better performance. 
  name                                  = var.db_name
  username                              = var.db_username
  password                              = var.db_pass 
  port                                  = var.db_port 
  storage_encrypted                     = var.db_encrypted 
  multi_az                              = var.multi_availability_zone   // for ha keep single az off while this is on 
  // availability_zone                     = var.availability_zone       // in case of single az -- keep it off while multi-az enabled.
  skip_final_snapshot                   = var.skip_final_snapshot
//   kms_key_id                         = "arm:aws:kms:<region>:<account id>:key/<kms key id>"
  parameter_group_name                  = var.parameter_group_name    //settings you want to apply if saved previously
  deletion_protection                   = var.deletion_protection 

  tags = {
      Owner                               = var.tag_owner,
      Environment                         = var.tag_environment,
      Role                                = var.tag_role,
      creater                             = var.tag_creater,
      Creation_date                       = var.tag_creation_date,
      Name                                = var.tag_name
    }
  
  maintenance_window                    = var.maintenance_window 
  backup_window                         = var.backup_window 
  backup_retention_period               = var.backup_retention_period       // this will retain your backup for specified days. 
  allow_major_version_upgrade           = var.allow_major_version_upgrade   // this will allow major version upgrade
  apply_immediately                     = var.apply_immediately             // this will apply those changes immediately. must keep it false
  auto_minor_version_upgrade            = var.auto_minor_version_upgrade    // 

  ## domain##
  // domain                                = var.domain                        // in case, you want to specify a domain for the db
  // domain_iam_role_name                  = var.domain_iam_role_name          // also you can specify domain iam role name

  

  ## enhanced monitoring##
  monitoring_interval                   = var.monitoring_interval
  monitoring_role_arn                  = var.monitoring_role_arn   
  // create_monitoring_role                = var.create_monitoring_role 
  enabled_cloudwatch_logs_exports       = var.cloudwatch_logs_exports


  # Snapshot name upon DB deletion
  final_snapshot_identifier             = var.final_snapshot_identifier 

  copy_tags_to_snapshot                 = var.copy_tags_to_snapshot
  vpc_security_group_ids                = var.sg_ids              // this has to be called internally.
  db_subnet_group_name                  = aws_db_subnet_group.non-default_vpc.id    // look at this later
  // ca_cert_identifier                    = "rds-ca-2019"
  // allowed_cidr_blocks                   = var.allowed_cidr_blocks 

  // db_parameter = [                                                     // use this when you want custom parameters for your db
  //     { name  = var.para1           value = var.value1  },
  //     { name  = var.para2           value = var.value2  }
  //   ]

}

