provider "aws" {
  alias                   = "north"
  region                  = "us-east-1"
  shared_credentials_file = "~/.aws/creds"
  profile                 = "jeet-terraform"
}

provider "aws" {
  alias                   = "ohio"
  region                  = "us-east-2"
  shared_credentials_file = "~/.aws/creds"
  profile                 = "jeet-terraform"
}

locals {
  env                     = terraform.workspace
}

module "vpc" {
  source            = "./vpc"
  providers = {
    aws   = aws.north
  }
  vpc_name          = "vpc-terraform_${local.env}"
  cidr_vpc          = "10.10.0.0/16"
  environment_tag   = "terraform_${local.env}"
  cidr_pub          = "10.10.1.0/24"
  az                = "us-east-1a"
  az_app1           = "us-east-1a"
  az_app2           = "us-east-1b"
  az_db1            = "us-east-1a"
  az_db2            = "us-east-1b"
  cidr_app1         = "10.10.2.0/24"
  cidr_app2         = "10.10.3.0/24"
  cidr_db1          = "10.10.4.0/24"
  cidr_db2          = "10.10.5.0/24"
  igw_name          = "testigw_${local.env}"
  // peering_id        = module.peering.peering_id_${local.env}
}

###Security-Group###

module "sg" {
  source                              = "./sg"
  providers = {
    aws   = aws.north
  }
  vpc_id      = module.vpc.vpc_id_created
  cidr_blocks = ["103.95.81.63/32", "10.10.1.0/24"]
}


#######RDS-Postgres-Creation######
module "rds" {
  source                                ="./rds"
  providers         = {
    aws             = aws.north
  }
  ##Subnet Group##
  subnet_ids                            = [module.vpc.public_subnet_id_created, module.vpc.db_subnet2_id_created]
  database_identifier                   = "db-terraform-${local.env}"  // in database name, you can't use "_" use "-"
  allocated_storage                     = 20                        
  max_allocated_storage                 = 50
  storage_type                          = "gp2"                    // gp2 (20GB-16TB) or io1 (100GB-16TB and 1000-80000 iops)     
  // iops                                  = "1000"                     // when set, also need to change storage type to io1
  engine                                = "postgres"
  engine_version                        = 11
  instance_class                        = "db.t2.micro"
  db_name                               = "dbtester_${local.env}"
  db_username                           = "dbuser"
  db_pass                               = "itsmydbpass"
  db_port                               = 5432
  db_encrypted                          = false            // true/false
  subnet_group_name                     = "custom_subnet_group_${local.env}"
  // db_parameter_group                    = "default.postgres11"
  parameter_group_name                  = "default.postgres11"
  deletion_protection                   = false
  tag_owner                             = "myself_${local.env}"
  tag_environment                       = "test_${local.env}"
  tag_role                              = "test-terraform_${local.env}"
  tag_creater                           = "jeet_${local.env}"
  tag_creation_date                     = "10-20-30_${local.env}"
  tag_name                              = "terraform-rds_${local.env}"
  maintenance_window                    = "Mon:00:00-Mon:03:00"
  backup_window                         = "03:00-06:00"
  backup_retention_period               = 7
  allow_major_version_upgrade           = false
  apply_immediately                     = false
  auto_minor_version_upgrade            = false
  monitoring_interval                   = 0
  monitoring_role_arn                  = ""                       //  it is necessary to give monitoring_role_arn if interval is >0
  // create_monitoring_role                = true
  final_snapshot_identifier             = "snapshot-before-deletion"
  copy_tags_to_snapshot                 = true
  sg_ids                                = [module.sg.sg_created]
  // allowed_cidr_blocks                   = ["10.10.2.0/24"]
  multi_availability_zone               = true
  // availability_zone                     = "us-east-1a"                            // if given will deploy single az db. 
  skip_final_snapshot                   = true
  cloudwatch_logs_exports               = ["postgresql"]
  // ##db_parameters########
  // para1                                 = "myisam_sort_buffer_size" 
  // value1                                = "1048576"
  // para2                                 = "sort_buffer_size" 
  // value2                                = "2097152"
}

