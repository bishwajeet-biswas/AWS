provider "google" {
  credentials = file("service-account.json")
  project = "xap-test1"
  region = "us-central1"
}

provider "google-beta" {
  credentials = file("service-account.json")
  project = "xap-test1"
  region = "us-central1"
}

//public: true:false decides your sql to stay private or public

module "sql" {
  source                    = "./modules/"
  machine_type              = "db-custom-1-3840"    //db custom starts with "db" and minimum memory for custom type is 3840 MB
#   machine_type              = "db-f1-micro"
  private_ip_address_name   = "globalinternalprivateip"
  vpc_name                  = "k8cluster"
  public                    = "false"               // can be "true" or "false"
  sql_name                  = "testjeet125"
  region                    = "us-central1" 
  db-version                = "POSTGRES_11"
  db-password               = "Welcome123"
  db-password2              = "Welcome123"
  auth_networks             = "146.196.35.231/32"   //public ip only
  auth_networks2            = "146.196.35.230/32"   // public ip only
  availability              = "ZONAL"               // REGIONAL/ZONAL
  disk-type                 = "PD_SSD"              // can pe "PD_SSD" or "PD_HDD"
  disk-size                 = "10"                  //if this is set do not set disk_autoresize
  disk-autoresize           = "false"               // if this is set do not set disk_size; when selected by default disk size is 10GB and than it increases as required. 
  ############LABELS############
  label_env                 = "test"
  label_created_by          = "bishwajeet"
  label_creation_date       = "14th-april"
  label_owner               = "jeet"
  label_requester           = "testing-me"
}

