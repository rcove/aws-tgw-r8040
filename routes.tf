############################################
########### Management VPC  ################
############################################

# Create a Management VPC route tables
resource "aws_route_table" "Management_route_table" {
  vpc_id     = "${aws_vpc.management_vpc.id}"

  # Route to the internet
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.management_internet_gateway.id}"
  }

  # Route to the Outbound Security VPC 
  route {
    cidr_block         = "${var.outbound_cidr_vpc}"
    transit_gateway_id = "${aws_ec2_transit_gateway.transit_gateway.id}"
  }

  # Route to the Inbound Security VPC 
  route {
    cidr_block         = "${var.inbound_cidr_vpc}"
    transit_gateway_id = "${aws_ec2_transit_gateway.transit_gateway.id}"
  }
   # Routes to Spokes
  route {
    cidr_block         = "${var.spoke_1_cidr_vpc}"
    transit_gateway_id = "${aws_ec2_transit_gateway.transit_gateway.id}"
  }
  route {
    cidr_block         = "${var.spoke_1a_cidr_vpc}"
    transit_gateway_id = "${aws_ec2_transit_gateway.transit_gateway.id}"
  }
  route {
    cidr_block         = "${var.spoke_2_cidr_vpc}"
    transit_gateway_id = "${aws_ec2_transit_gateway.transit_gateway.id}"
  }
  
  tags {
    Name = "${var.project_name}-Management-External-Route"
  }
}

resource "aws_route_table_association" "management_table_association" {
  subnet_id      = "${aws_subnet.management_subnet.id}"
  route_table_id = "${aws_route_table.Management_route_table.id}"
}

##########################################
########### Inbound VPC  #################
##########################################

# Create Inbound route tables
resource "aws_route_table" "inbound_route_table" {
  vpc_id     = "${aws_vpc.inbound_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.inbound_internet_gateway.id}"
  }

  # Routes to Spokes
  route {
    cidr_block         = "${var.spoke_1_cidr_vpc}"
    transit_gateway_id = "${aws_ec2_transit_gateway.transit_gateway.id}"
  }
  route {
    cidr_block         = "${var.spoke_1a_cidr_vpc}"
    transit_gateway_id = "${aws_ec2_transit_gateway.transit_gateway.id}"
  }
  route {
    cidr_block         = "${var.spoke_2_cidr_vpc}"
    transit_gateway_id = "${aws_ec2_transit_gateway.transit_gateway.id}"
  }
  
  # Route to the Management VPC
  route {
    cidr_block         = "${var.management_cidr_vpc}"
    transit_gateway_id = "${aws_ec2_transit_gateway.transit_gateway.id}"
  }


  tags {
    Name = "${var.project_name}-Inbound-Route-Table"
  }
}

resource "aws_route_table_association" "inbound_table_association" {
  count          = "${length(data.aws_availability_zones.azs.names)}"
  subnet_id      = "${element(aws_subnet.inbound_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.inbound_route_table.id}"
}

##########################################
########### Outbound VPC  ################
##########################################

data "aws_route_table" "data_outbound_asg_route_table" {
  filter {
    name   = "tag:aws:cloudformation:stack-name"
    values = ["${var.project_name}-Outbound-ASG-VPCStack-*"]
  }

  depends_on = ["aws_cloudformation_stack.checkpoint_tgw_cloudformation_stack"]
}

# Route to the Management VPC - Control channel through a VPC attachment, not through the VPN tunnels
resource "aws_route" "outbound_to_management_route" {
  route_table_id         = "${data.aws_route_table.data_outbound_asg_route_table.id}"
  destination_cidr_block = "${var.management_cidr_vpc}"
  transit_gateway_id     = "${aws_ec2_transit_gateway.transit_gateway.id}"
}

######################################
########### Spoke-1 VPC  #############
######################################

# Create a route table
resource "aws_route_table" "spoke_1_route_table" {
  vpc_id     = "${aws_vpc.spoke_1_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    transit_gateway_id = "${aws_ec2_transit_gateway.transit_gateway.id}"
  }

  tags {
    Name = "${var.project_name}-Spoke-1-Route"
  }
}

resource "aws_route_table_association" "spoke-1_route_table_association" {
  count          = "${length(data.aws_availability_zones.azs.names)}"
  subnet_id      = "${element(aws_subnet.spoke_1_external_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.spoke_1_route_table.id}"
}


######################################
########### Spoke-1a VPC  #############
######################################

# Create a route table (default to TGW)
resource "aws_route_table" "spoke_1a_route_table" {
  vpc_id     = "${aws_vpc.spoke_1a_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    transit_gateway_id = "${aws_ec2_transit_gateway.transit_gateway.id}"
  }

  tags {
    Name = "${var.project_name}-Spoke-1a-Route"
  }
}

resource "aws_route_table_association" "spoke-1a_route_table_association" {
  count          = "${length(data.aws_availability_zones.azs.names)}"
  subnet_id      = "${element(aws_subnet.spoke_1a_external_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.spoke_1a_route_table.id}"
}

######################################
########### Spoke-2 VPC  #############
######################################

# Create/Update routes
resource "aws_route_table" "spoke_2_route_table" {
  vpc_id     = "${aws_vpc.spoke_2_vpc.id}"

  route {
    cidr_block          = "0.0.0.0/0"
	  transit_gateway_id  = "${aws_ec2_transit_gateway.transit_gateway.id}"
  }

  tags {
    Name = "${var.project_name}-Spoke-2-Route"
  }
}

resource "aws_route_table_association" "spoke_2_route_table_association" {
  count          = "${length(data.aws_availability_zones.azs.names)}"
  subnet_id      = "${aws_subnet.spoke_2_external_subnet.id}"
  route_table_id = "${aws_route_table.spoke_2_route_table.id}"
}


###########################################################
######## Transit GW - Outbound Spokes Route Table #########
###########################################################

# Create an route table for outbound spoke-to-Internet traffic.
# This Route Table will be associated to spokes which are not exposed to the internet.
# It will handle all traffic from those spokes including spokes-to-Internet and spoke-to-spoke traffic
resource "aws_ec2_transit_gateway_route_table" "spoke_to_internet_transit_gateway_route_table" {
  transit_gateway_id = "${aws_ec2_transit_gateway.transit_gateway.id}"
  tags {
    Name        = "${var.project_name}-TransitGW-Outbound-Spoke-Route-Table"
    x-chkp-vpn  = "${var.template_management_server_name}/${var.vpn_community_name}/propagate"
  }
}

# Create route association - Associate Spoke-2 to this Route Table
resource "aws_ec2_transit_gateway_route_table_association" "spoke_2_transit_gateway_route_table_association" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.spoke_2_transit_gateway_vpc_attachment.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.spoke_to_internet_transit_gateway_route_table.id}"
} 

##########################################################
######## Transit GW - Inbound Spokes Route Table #########
##########################################################

# Create an route table for inbound Internet-to-spoke. 
# This Route Table is for spokes which are exposed to the Internet. 
# It will handle all traffic from those spokes including internet-to-spoke, spoke-to-internet and spoke-to-spoke
resource "aws_ec2_transit_gateway_route_table" "spoke_inbound_transit_gateway_route_table" {
  transit_gateway_id = "${aws_ec2_transit_gateway.transit_gateway.id}"

# Routes for spoke-to-internet and spoke-to-spoke will be handled by the Outbound Security VPC
# Those routes will be automatically provisioned by Management, based on the Route Table tags
  tags {
    Name        = "${var.project_name}-TransitGW-Inbound-Spoke-Route-Table"
    x-chkp-vpn  = "${var.template_management_server_name}/${var.vpn_community_name}/propagate"
  }
}

# Create route association - Associate Spoke-1 to this Route Table
resource "aws_ec2_transit_gateway_route_table_association" "spoke_1_transit_gateway_route_table_association" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.spoke_1_transit_gateway_vpc_attachment.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.spoke_inbound_transit_gateway_route_table.id}"
} 

# Create route association - Associate Spoke-1a to this Route Table
resource "aws_ec2_transit_gateway_route_table_association" "spoke_1a_transit_gateway_route_table_association" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.spoke_1a_transit_gateway_vpc_attachment.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.spoke_inbound_transit_gateway_route_table.id}"
} 

# Create route propagation - This is for replies to internet-to-spoke traffic
resource "aws_ec2_transit_gateway_route_table_propagation" "checkpoint_inbound_transit_gateway_route_table_propagation" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.inbound_transit_gateway_vpc_attachment.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.spoke_inbound_transit_gateway_route_table.id}"
}

########################################################
##### Transit GW - Outbound Security Route Table #######
########################################################

# Create a route table for the Outbound Check Point VPC
resource "aws_ec2_transit_gateway_route_table" "checkpoint_outbound_transit_gateway_route_table" {
  transit_gateway_id = "${aws_ec2_transit_gateway.transit_gateway.id}"

# Routes for spoke-to-internet and spoke-to-spoke will be handled by the Outbound Security VPC
# Those routes will be automatically provisioned by Management, based on the Route Table tags
  tags {
    Name        = "${var.project_name}-TransitGW-Outbound-CheckPoint-Route-Table"
    x-chkp-vpn  = "${var.template_management_server_name}/${var.vpn_community_name}/associate"
  }
}

# Create route association - This will only be used for the control plane
resource "aws_ec2_transit_gateway_route_table_association" "checkpoint_outbound_transit_gateway_route_table_association" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.outbound_transit_gateway_vpc_attachment.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.checkpoint_outbound_transit_gateway_route_table.id}"
} 

# Create route propagation - Add routes to the spoke VPCs
resource "aws_ec2_transit_gateway_route_table_propagation" "spoke_1_outbound_transit_gateway_route_table_propagation" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.spoke_1_transit_gateway_vpc_attachment.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.checkpoint_outbound_transit_gateway_route_table.id}"
}

# Create route propagation - Add routes to the spoke VPCs
resource "aws_ec2_transit_gateway_route_table_propagation" "spoke_1a_outbound_transit_gateway_route_table_propagation" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.spoke_1a_transit_gateway_vpc_attachment.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.checkpoint_outbound_transit_gateway_route_table.id}"
}

resource "aws_ec2_transit_gateway_route_table_propagation" "spoke_2_outbound_transit_gateway_route_table_propagation" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.spoke_2_transit_gateway_vpc_attachment.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.checkpoint_outbound_transit_gateway_route_table.id}"
}

### Control Plane - Add a route to the Management VPC ###
resource "aws_ec2_transit_gateway_route_table_propagation" "outbound_management_transit_gateway_route_table_propagation" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.management_transit_gateway_vpc_attachment.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.checkpoint_outbound_transit_gateway_route_table.id}"
}

#######################################################
##### Transit GW - Inbound Security Route Table #######
#######################################################

# Create a route table for the Inbound Check Point VPC 
resource "aws_ec2_transit_gateway_route_table" "checkpoint_inbound_transit_gateway_route_table" {
  transit_gateway_id = "${aws_ec2_transit_gateway.transit_gateway.id}"
  tags {
    Name        = "${var.project_name}-TransitGW-Inbound-CheckPoint-Route-Table"
  }
}

# Create route association
resource "aws_ec2_transit_gateway_route_table_association" "checkpoint_inbound_transit_gateway_route_table_association" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.inbound_transit_gateway_vpc_attachment.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.checkpoint_inbound_transit_gateway_route_table.id}"
} 

# Create route propagation - Add routes to the spoke VPCs
resource "aws_ec2_transit_gateway_route_table_propagation" "spoke_1_inbound_transit_gateway_route_table_propagation" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.spoke_1_transit_gateway_vpc_attachment.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.checkpoint_inbound_transit_gateway_route_table.id}"
}

# Create route propagation - Add routes to the spoke VPCs
resource "aws_ec2_transit_gateway_route_table_propagation" "spoke_1a_inbound_transit_gateway_route_table_propagation" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.spoke_1a_transit_gateway_vpc_attachment.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.checkpoint_inbound_transit_gateway_route_table.id}"
}

### Control Plane - Add a route to the Management VPC ###
resource "aws_ec2_transit_gateway_route_table_propagation" "inbound_management_transit_gateway_route_table_propagation" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.management_transit_gateway_vpc_attachment.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.checkpoint_inbound_transit_gateway_route_table.id}"
}

#################################################
##### Transit GW - Management Route Table #######
#################################################

# Create a route table for a management control plane
resource "aws_ec2_transit_gateway_route_table" "checkpoint_management_transit_gateway_route_table" {
  transit_gateway_id = "${aws_ec2_transit_gateway.transit_gateway.id}"
  tags {
    Name        = "${var.project_name}-TransitGW-Management-CheckPoint-Route-Table"
  }
}
# Create route association
resource "aws_ec2_transit_gateway_route_table_association" "checkpoint_management_transit_gateway_route_table_association" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.management_transit_gateway_vpc_attachment.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.checkpoint_management_transit_gateway_route_table.id}"
} 

# Create route propagation - Add a route to the Inbound and Outbound Security VPCs
resource "aws_ec2_transit_gateway_route_table_propagation" "management_outbound_transit_gateway_route_table_propagation" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.outbound_transit_gateway_vpc_attachment.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.checkpoint_management_transit_gateway_route_table.id}"
}

resource "aws_ec2_transit_gateway_route_table_propagation" "management_inbound_transit_gateway_route_table_propagation" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.inbound_transit_gateway_vpc_attachment.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.checkpoint_management_transit_gateway_route_table.id}"
}

