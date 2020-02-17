#####################################
######### Transit GW  ###############
#####################################

# Create the TGW
resource "aws_ec2_transit_gateway" "transit_gateway" {
  description = "${var.project_name}"
  auto_accept_shared_attachments = "enable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags {
    Name        = "${var.project_name}"
    x-chkp-vpn  = "${var.template_management_server_name}/${var.vpn_community_name}"
  }
}

#####################################
######### Management VPC ############
#####################################

# Attach the Management VPC to the TGW
resource "aws_ec2_transit_gateway_vpc_attachment" "management_transit_gateway_vpc_attachment" {
  subnet_ids         = ["${aws_subnet.management_subnet.id}"]
  transit_gateway_id = "${aws_ec2_transit_gateway.transit_gateway.id}"
  vpc_id             = "${aws_vpc.management_vpc.id}"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags {
    Name = "${var.project_name}-Management-TGW-Attachment"
  }
} 

#####################################
######### Outbound VPC ##############
#####################################

# Attach the Outbound Security VPC to the TGW - This is for the management control plane
resource "aws_ec2_transit_gateway_vpc_attachment" "outbound_transit_gateway_vpc_attachment" {
  subnet_ids         = ["${data.aws_subnet.outbound_subnet.*.id}"]
  transit_gateway_id = "${aws_ec2_transit_gateway.transit_gateway.id}"
  vpc_id             = "${data.aws_vpc.data_outbound_asg_vpc.id}"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags {
    Name = "${var.project_name}-Outbound-TGW-Attachment"
  }
} 

#####################################
######### Inbound VPC ###############
#####################################

# Attach the Inbound Seucirty VPC to the TGW
resource "aws_ec2_transit_gateway_vpc_attachment" "inbound_transit_gateway_vpc_attachment" {
  subnet_ids         = ["${aws_subnet.inbound_subnet.*.id}"]
  transit_gateway_id = "${aws_ec2_transit_gateway.transit_gateway.id}"
  vpc_id             = "${aws_vpc.inbound_vpc.id}"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags {
    Name = "${var.project_name}-Inbound-TGW-Attachment"
  }
} 

#####################################
######### Spoke-1 VPC ###############
#####################################
# Attach Spoke-1 VPC to the TGW 
resource "aws_ec2_transit_gateway_vpc_attachment" "spoke_1_transit_gateway_vpc_attachment" {
  subnet_ids         = ["${aws_subnet.spoke_1_external_subnet.*.id}"]
  transit_gateway_id = "${aws_ec2_transit_gateway.transit_gateway.id}"
  vpc_id             = "${aws_vpc.spoke_1_vpc.id}"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags {
    Name = "${var.project_name}-Spoke-1-TGW-Attachment"
  }
}

#####################################
######### Spoke-1a VPC ###############
#####################################
# Attach Spoke-1a VPC to the TGW 
resource "aws_ec2_transit_gateway_vpc_attachment" "spoke_1a_transit_gateway_vpc_attachment" {
  subnet_ids         = ["${aws_subnet.spoke_1a_external_subnet.*.id}"]
  transit_gateway_id = "${aws_ec2_transit_gateway.transit_gateway.id}"
  vpc_id             = "${aws_vpc.spoke_1a_vpc.id}"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags {
    Name = "${var.project_name}-Spoke-1a-TGW-Attachment"
  }
}

#####################################
######### Spoke-2 VPC ###############
#####################################

# Attach Spoek-2 VPC to the TGW
resource "aws_ec2_transit_gateway_vpc_attachment" "spoke_2_transit_gateway_vpc_attachment" {
  subnet_ids         = ["${aws_subnet.spoke_2_external_subnet.id}"]
  transit_gateway_id = "${aws_ec2_transit_gateway.transit_gateway.id}"
  vpc_id             = "${aws_vpc.spoke_2_vpc.id}"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  tags {
    Name = "${var.project_name}-Spoke-2-TGW-Attachment"
  } 
}
