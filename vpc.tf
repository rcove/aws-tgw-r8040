##########################################
########### Management VPC  ##############
##########################################

# Create a VPC for the Management Server
resource "aws_vpc" "management_vpc" {
  cidr_block            = "${var.management_cidr_vpc}"
  enable_dns_hostnames  = "true"
  
  tags {
    Name = "${var.project_name}-Management-VPC"
  }
}

# Create an internet gateway to give internet access
resource "aws_internet_gateway" "management_internet_gateway" {
  vpc_id = "${aws_vpc.management_vpc.id}"
  
  tags {
    Name   = "${var.project_name}-Management-IGW"
  }
}

# A permissive security group
resource "aws_security_group" "management_security_group" {
  vpc_id     = "${aws_vpc.management_vpc.id}"
  
  # Full inbound access
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }    
  # internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }     
  
  tags {
    Name   = "${var.project_name}-Management-SG"
  }
}

##########################################
########### Outbound VPC  ################
##########################################

data "aws_vpc" "data_outbound_asg_vpc" {
  filter {
    name   = "tag:Name"
    values = ["${var.project_name}-Outbound-ASG-VPCStack-*"]
  }
  depends_on = ["aws_cloudformation_stack.checkpoint_tgw_cloudformation_stack"]
}

##########################################
########### Inbound VPC  #################
##########################################

# Create a VPC for the Inbound ASG
resource "aws_vpc" "inbound_vpc" {
  cidr_block            = "${var.inbound_cidr_vpc}"
  enable_dns_hostnames  = "true"
  
  tags {
    Name = "${var.project_name}-Inbound-VPC"
  }
}

# Create an internet gateway to give internet access
resource "aws_internet_gateway" "inbound_internet_gateway" {
  vpc_id = "${aws_vpc.inbound_vpc.id}"
  
  tags {
    Name   = "${var.project_name}-Inbound-IGW"
  }
}

# A permissive security group
resource "aws_security_group" "inbound_security_group" {
  vpc_id     = "${aws_vpc.inbound_vpc.id}"
  
  # Full inbound access
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }    
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }     
  
  tags {
    Name   = "${var.project_name}-Inbound-SG"
  }
}

######################################
########### Spoke-1 VPC  #############
######################################

# Create a test VPC and launch a public facing web server
resource "aws_vpc" "spoke_1_vpc" {
  cidr_block            = "${var.spoke_1_cidr_vpc}"
  enable_dns_hostnames  = "true"
  
  tags {
    Name = "${var.project_name}-Spoke-1-VPC"
  }
}

# A security group to give access via the web
resource "aws_security_group" "spoke_1_security_group" {
  vpc_id     = "${aws_vpc.spoke_1_vpc.id}"
  
  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }  
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "ICMP"
    cidr_blocks = ["0.0.0.0/0"]
  }   
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }    

  tags {
    Name   = "${var.project_name}-Spoke-1-SG"
  }  
}

######################################
########### Spoke-1a VPC  #############
######################################

# Create a test VPC and launch a second public facing web server
resource "aws_vpc" "spoke_1a_vpc" {
  cidr_block            = "${var.spoke_1a_cidr_vpc}"
  enable_dns_hostnames  = "true"
  
  tags {
    Name = "${var.project_name}-Spoke-1a-VPC"
  }
}

# A security group to give access via the web
resource "aws_security_group" "spoke_1a_security_group" {
  vpc_id     = "${aws_vpc.spoke_1a_vpc.id}"
  
  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }  
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "ICMP"
    cidr_blocks = ["0.0.0.0/0"]
  }   
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }    

  tags {
    Name   = "${var.project_name}-Spoke-1a-SG"
  }  
}

######################################
########### Spoke-2 VPC  #############
######################################

# Create a test VPC to launch a testing linux host 
resource "aws_vpc" "spoke_2_vpc" {
  cidr_block            = "${var.spoke_2_cidr_vpc}"
  enable_dns_hostnames  = "true"
  
  tags {
    Name = "${var.project_name}-Spoke-2-VPC"
  }
}

# A security group to give access via the web
resource "aws_security_group" "spoke_2_security_group" {
  vpc_id     = "${aws_vpc.spoke_2_vpc.id}"
  
  # Full tester inbound access
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }    
  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }     
  
  tags {
    Name   = "${var.project_name}-Spoke-2-SG"
  }
}