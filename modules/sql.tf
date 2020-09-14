# resource "google_sql_database_instance" "master" {
#   name             = "master-instance"
#   database_version = "POSTGRES_11"
#   region           = "us-central1"

#   settings {
#     # Second-generation instance tiers are based on the machine
#     # type. See argument reference below.
#     tier = "db-f1-micro"
#   }
# }


// this creates a vpc which in practical case, we'll be using the exiting one

# resource "google_compute_network" "private_network" {
#   provider = google-beta

#   name = "private-network"
# }
#############variables##############
variable "private_ip_address_name" {}
variable "vpc_name" {}
variable "public" {}
variable "sql_name" {}
variable "region" {}
variable "machine_type" {}
variable "db-version" {}
variable "availability" {}
variable "disk-size" {}
variable "disk-type" {}
variable "disk-autoresize" {}
variable "label_env" {}
variable "label_created_by" {}
variable "label_creation_date" {}
variable "label_requester" {}
variable "label_owner" {}
variable "db-password" {}
variable "db-password2" {}
variable "auth_networks" {}
variable "auth_networks2" {}


################################

// this will create a global IP address 
// Global static external IP addresses are available only to global forwarding rules, used for global load balancing. You can't assign a global IP address to a regional or zonal resource.
resource "google_compute_global_address" "private_ip_address" {
  provider = google-beta

  name          = var.private_ip_address_name
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL" // always internal
  prefix_length = 16
  network       = var.vpc_name
#   network       = google_compute_network.private_network.self_link
}

// this will create a vpc peering connection with google where sql is actually created
// google just gives the global ip address which is the forwarding rule at their end. 

resource "google_service_networking_connection" "private_vpc_connection" {
  provider = google-beta

  network                 = var.vpc_name
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

//I don't want my sql to be named randomly

# resource "random_id" "db_name_suffix" {
#   byte_length = 4
# }

// here we create the sql database now

resource "google_sql_database_instance" "instance" {
  provider = google-beta

  name              = var.sql_name
  database_version  = var.db-version
#   availability_type = var.availability
  region            = var.region
  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
      // for more instance types https://cloud.google.com/sql/pricing
    tier                = var.machine_type
    availability_type   = var.availability
    disk_autoresize     = var.disk-autoresize
    disk_size           = var.disk-size
    disk_type           = var.disk-type

    backup_configuration {
            enabled = "true"
        }
    maintenance_window {
            day             = "7"
            hour            = "16"
            update_track    = "stable"
            
    }

    database_flags {
            name = "log_min_duration_statement" 
            value = "1000"
    }
    user_labels = {
        environment     = var.label_env
        created_by      = var.label_created_by
        creation_date   = var.label_creation_date
        requester       = var.label_requester
        owner           = var.label_owner
        creation_mode   = "terraform"
    }
    # tier = "db-f1-micro"
    ip_configuration {

        authorized_networks {
            name            = "from_office_ip"
            value           = var.auth_networks         
        }
        authorized_networks {
            name            = "from_devloper_team"
            value           = var.auth_networks2         
        } 
        ipv4_enabled        = var.public
        private_network     = "projects/xap-test1/global/networks/${var.vpc_name}"  // this decides which vpc to access this sql instance
        require_ssl         = "false"
    #   private_network = google_compute_network.private_network.self_link
    }
  }
}
resource "google_sql_user" "master-users" {
  name     = "postgres_jeet"
  instance = google_sql_database_instance.instance.name
  password = var.db-password
}
resource "google_sql_user" "another-user" {
  name      = "developer"
  instance  = google_sql_database_instance.instance.name
  password  = var.db-password2
}
