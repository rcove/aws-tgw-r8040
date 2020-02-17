##########################################
########### Management VPC  ##############
##########################################

# Create subnets to launch our instances into
resource "aws_subnet" "management_subnet" {
  vpc_id            = "${aws_vpc.management_vpc.id}"
  cidr_block        = "${cidrsubnet(var.management_cidr_vpc, 8, 1 )}"
  availability_zone = "ap-southeast-2a"
  
  tags {
    Name = "${var.project_name}-Management"
  }
}

########################################
########### Outbound VPC  ##############
########################################

data "aws_subnet_ids" "outbound_subnet_ids" {
  vpc_id = "${data.aws_vpc.data_outbound_asg_vpc.id}"

  tags = {
    Name =  "Public subnet*"
  }
  
  depends_on = ["aws_cloudformation_stack.checkpoint_tgw_cloudformation_stack"]
}

data "aws_subnet" "outbound_subnet" {
  count = "${length(data.aws_availability_zones.azs.names)}"
  id    = "${data.aws_subnet_ids.outbound_subnet_ids.ids[count.index]}"
}


#######################################
########### Inbound VPC  ##############
#######################################

# Create subnets to launch our instances into
resource "aws_subnet" "inbound_subnet" {
  count             = "${length(data.aws_availability_zones.azs.names)}"
  availability_zone = "${element(data.aws_availability_zones.azs.names, count.index)}"
  vpc_id            = "${aws_vpc.inbound_vpc.id}"
  cidr_block        = "${cidrsubnet(var.inbound_cidr_vpc, 8, count.index+100 )}"
  
  tags {
    Name = "${var.project_name}-Inbound-${count.index+1}"
  }
}

#####################################
########### Spoke-1 VPC  ############
#####################################

# Create a subnet to launch our instances into
resource "aws_subnet" "spoke_1_external_subnet" {
  count             = "${length(data.aws_availability_zones.azs.names)}"
  availability_zone = "${element(data.aws_availability_zones.azs.names, count.index)}"
  vpc_id            = "${aws_vpc.spoke_1_vpc.id}"
  cidr_block        = "${cidrsubnet(var.spoke_1_cidr_vpc, 8, count.index+100 )}"
  
  tags {
    Name = "${var.project_name}-Spoke-1-External-${count.index+1}"
  }
}

######################################
########### Spoke-2 VPC  #############
######################################

# Create a subnet to launch our instances into
resource "aws_subnet" "spoke_2_external_subnet" {
  vpc_id     = "${aws_vpc.spoke_2_vpc.id}"
  cidr_block = "${var.spoke_2_cidr_vpc}"
  
  tags {
    Name = "${var.project_name}-Spoke-2-External"
  }
}


#####################################
########### Spoke-1a VPC  ############
#####################################

# Create a subnet to launch our instances into
resource "aws_subnet" "spoke_1a_external_subnet" {
  count             = "${length(data.aws_availability_zones.azs.names)}"
  availability_zone = "${element(data.aws_availability_zones.azs.names, count.index)}"
  vpc_id            = "${aws_vpc.spoke_1a_vpc.id}"
  cidr_block        = "${cidrsubnet(var.spoke_1a_cidr_vpc, 8, count.index+100 )}"
  
  tags {
    Name = "${var.project_name}-Spoke-1a-External-${count.index+1}"
  }
}
