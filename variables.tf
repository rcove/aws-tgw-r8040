variable "project_name" {
  description = "Project Name - will prefex all generated AWS resource names"
  default = "CP-TGW"
}


######################################
######## Account Settings ############
######################################

provider "aws" {
#  shared_credentials_file = "~/.aws/credentials"
#  shared_credentials_file = "%USERPROFILE%\.aws\credentials"
  /*
      Shared credential files is a text file with the following format:
        [<PROFILE>]
        aws_access_key_id = <ACCESS_KEY_ID>
        aws_secret_access_key = <SECRET_ACCESS_KEY
  */
  profile = "default"
  region  = "${var.region}"
}
variable "region" {
  default = "ap-southeast-2"
}


data "aws_availability_zones" "azs" {}

# Private key
variable "key_name" {
  description = "Must be the name of an existing EC2 KeyPair"
  default = "rich-lab"
}

#########################################
############# Topology ##################
#########################################

# Managemnt VPC
variable "management_cidr_vpc" {
  description = "Check Point Management VPC"
  default     = "10.10.0.0/16"
}

# Inbound VPC
variable "inbound_cidr_vpc" {
  description = "Check Point Inbound VPC"
  default     = "10.20.0.0/16"
}

# Outbound VPC
variable "outbound_cidr_vpc" {
  description = "Check Point Outbound VPC"
  default     = "10.30.0.0/16"
}

# VPC hosting out private facing website
variable "spoke_1_cidr_vpc" {
  description = "VPC hosting an internet facing website"
  default     = "10.110.0.0/16"
}
# VPC hosting second website
variable "spoke_1a_cidr_vpc" {
  description = "VPC hosting an internet facing website"
  default     = "10.111.0.0/16"
}

# VPC hosting a test endpoint
variable "spoke_2_cidr_vpc" {
  description = "VPC hosting a Linux testing server - no inbound access"
  default     = "10.120.0.0/16"
}

variable "spoke_1_high_port" {
  description = "Choose the (random-unique) high port that will be used to access the web server in Spoke-1"
  default     = "9080"
}
variable "app_1_high_port" {
  description = "Choose the (random-unique) high port that will be used to access the web server in Spoke-1"
  default     = "9081"
}
variable "app_2_high_port" {
  description = "Choose the (random-unique) high port that will be used to access the web server in Spoke-1"
  default     = "9082"
}


###########################################
############# Server Settings #############
###########################################
# Hashed password for the Check Point servers - you can generate this with the command 'openssl passwd -1 <PASSWORD>'
# (Optional) You can instead SSH into the server and run (from clish): 'set user admin password', fowlloed by 'save config'
variable "password_hash" {
  description = "Hashed password for the Check Point servers - this parameter is optional"
  default     = "$1$VqtPZ8Gq$.5o9coseXNVPPpR02RUz3/"
}

# SIC key
variable "sic_key" {
  description = "One time password used to established connection between the Management and the Security Gateway"
  default     = "abcdefgh"
}

variable "cpversion" {
  description = "Check Point version"
  default     = "R80.40"
}

variable "management_server_size" {
  default = "m5.large"
}

variable "outbound_asg_server_size" {
  default = "c5.large"
}

variable "inbound_asg_server_size" {
  default = "c5.large"
}


#############################################
######### Check Point Template Names ########
#############################################
variable "template_management_server_name" {
  description = "The name of the mangement server in the cloudformation template"
  default     = "tgw-management"
}

variable "outbound_configuration_template_name" {
  description = "The name of the outbound template name in the cloudformation template"
  default     = "tgw-outbound-template"
}

variable "inbound_configuration_template_name" {
  description = "The name of the inbound template name in the cloudformation template"
  default     = "tgw-inbound-template"
}
variable "vpn_community_name" {
  description = "The name of the VPN Community used by the TGW ASG"
  default     = "tgw-community"  
}
variable "externaldnshost" {
  description = "The name of the first website"
  default     = "www"  
}
variable "externaldnshostapp" {
  description = "The name of the second website"
  default     = "app"  
}
variable "externaldnshostalb" {
  description = "The name of the website defined by the alb"
  default     = "alb"  
}
variable "r53zone" {
  description = "The name of the domain used"
  default     = "mycloudguard.net"  
}
