##########################################
############# Management #################
##########################################
# Deploy CP Management cloudformation template - sk130372
# Run a user-data script to configure the manager with rules 
# and CME setup including the VPN mesh 
resource "aws_cloudformation_stack" "checkpoint_Management_cloudformation_stack" {
  name = "${var.project_name}-Management"

  parameters = {
    VPC             = aws_vpc.management_vpc.id
    Subnet          = aws_subnet.management_subnet.id
    Version         = "${var.cpversion}-BYOL"
    InstanceType    = var.management_server_size
    Name            = "${var.project_name}-Management"
    KeyName         = var.key_name
    PasswordHash    = var.password_hash
    Shell           = "/bin/bash"
    Permissions     = "Create with read-write permissions"
    BootstrapScript = <<BOOTSTRAP
echo 'clish -i -c "installer uninstall Check_Point_CPcme_Bundle_R80_40_T79.tgz last-take not-interactive" ,
sleep 15 ,
autoupdatercli enable CME ,
sleep 60 ,
autoprov-cfg -v ,
/opt/CPcme/bin/config-community ${var.vpn_community_name} ,
mgmt_cli -r true set access-rule layer Network rule-number 1 action "Accept" track "Log" ,
mgmt_cli -r true add access-layer name "Inline" ,
mgmt_cli -r true set access-rule layer Inline rule-number 1 action "Accept" track "Log" ,
mgmt_cli -r true add access-rule layer Network position 1 name "${var.vpn_community_name} VPN Traffic Rule" vpn.directional.1.from ${var.vpn_community_name} vpn.directional.1.to ${var.vpn_community_name} vpn.directional.2.from ${var.vpn_community_name} vpn.directional.2.to External_clear action "Apply Layer" inline-layer "Inline" ,
mgmt_cli -r true add nat-rule package standard position bottom install-on "Policy Targets" original-source All_Internet translated-source All_Internet method hide ,
autoprov-cfg -f init AWS -mn ${var.template_management_server_name} -tn ${var.outbound_configuration_template_name} -cn tgw-controller -po Standard -otp ${var.sic_key} -r ${var.region} -ver ${var.cpversion} -iam -dt TGW ,
autoprov-cfg -f set controller AWS -cn tgw-controller -slb ,
autoprov-cfg -f set controller AWS -cn tgw-controller -sg -sv -com ${var.vpn_community_name} ,
autoprov-cfg -f set template -tn ${var.outbound_configuration_template_name} -vpn -vd "" -con ${var.vpn_community_name} ,
autoprov-cfg -f set template -tn ${var.outbound_configuration_template_name} -ia -ips -appi -av -ab ,
autoprov-cfg -f add template -tn ${var.inbound_configuration_template_name} -otp ${var.sic_key} -ver ${var.cpversion} -po Standard -ia -ips -appi -av -ab ,
/opt/CPvsec-R80.40/bin/cloudguard on ' > /etc/cloud-setup.sh ,
chmod +x /etc/cloud-setup.sh ,
/etc/cloud-setup.sh ,
BOOTSTRAP

  }

  template_url       = "https://s3.amazonaws.com/CloudFormationTemplate/management.json"
  capabilities       = ["CAPABILITY_IAM"]
  disable_rollback   = true
  timeout_in_minutes = 50
}
# note: install log file in /var/log/cloud-user-data
# CME log file in 
# sed -i '/template_name/c\\${var.outbound_configuration_template_name}: autoscale-2-nic-management' /etc/cloud-version ,

##########################################
########### Outbound ASG  ################
##########################################
# East West and Egress traffic
# Deploy CP TGW cloudformation template
resource "aws_cloudformation_stack" "checkpoint_tgw_cloudformation_stack" {
  name = "${var.project_name}-Outbound-ASG"

  parameters = {
    VpcCidr                                  = var.outbound_cidr_vpc
    AvailabilityZones                        = join(", ", data.aws_availability_zones.azs.names)
    NumberOfAZs                              = length(data.aws_availability_zones.azs.names)
    PublicSubnetCidrA                        = cidrsubnet(var.outbound_cidr_vpc, 8, 0)
    PublicSubnetCidrB                        = cidrsubnet(var.outbound_cidr_vpc, 8, 64)
    PublicSubnetCidrC                        = cidrsubnet(var.outbound_cidr_vpc, 8, 128)
    PublicSubnetCidrD                        = cidrsubnet(var.outbound_cidr_vpc, 8, 196)
    ManagementDeploy                         = "No"
    KeyPairName                              = var.key_name
    GatewaysAddresses                        = var.outbound_cidr_vpc
    GatewayManagement                        = "Locally managed"
    GatewaysInstanceType                     = var.outbound_asg_server_size
    GatewaysMinSize                          = "1"
    GatewaysMaxSize                          = "2"
    GatewaysBlades                           = "On"
    GatewaysLicense                          = "${var.cpversion}-BYOL"
    GatewaysPasswordHash                     = var.password_hash
    GatewaysSIC                              = var.sic_key
    ControlGatewayOverPrivateOrPublicAddress = "private"
    ManagementServer                         = var.template_management_server_name
    ConfigurationTemplate                    = var.outbound_configuration_template_name
    Name                                     = "${var.project_name}-CheckPoint-TGW"
    Shell                                    = "/bin/bash"
  }

  template_url       = "https://s3.amazonaws.com/CloudFormationTemplate/checkpoint-tgw-asg-master.yaml"
  capabilities       = ["CAPABILITY_IAM"]
  disable_rollback   = true
  timeout_in_minutes = 50
}
##########################################
########### Inbound ASG  #################
##########################################
# Northbound hub
# Deploy CP ASG cloudformation template
resource "aws_cloudformation_stack" "checkpoint_inbound_asg_cloudformation_stack" {
  name = "${var.project_name}-Inbound-ASG"

  parameters = {
    VPC                                      = aws_vpc.inbound_vpc.id
    Subnets                                  = join(",", aws_subnet.inbound_subnet.*.id)
    ControlGatewayOverPrivateOrPublicAddress = "private"
    MinSize                                  = 1
    MaxSize                                  = 2
    ManagementServer                         = var.template_management_server_name
    ConfigurationTemplate                    = var.inbound_configuration_template_name
    Name                                     = "${var.project_name}-CheckPoint-Inbound-ASG"
    InstanceType                             = var.inbound_asg_server_size
    TargetGroups                             = "${aws_lb_target_group.external_lb_target_group.arn},${aws_lb_target_group.external_lb2_target_group.arn},${aws_lb_target_group.external_lb_tg_app1.arn},${aws_lb_target_group.external_lb_tg_app2.arn}"
    KeyName                                  = var.key_name
    PasswordHash                             = var.password_hash
    SICKey                                   = var.sic_key
    License                                  = "${var.cpversion}-BYOL"
    Shell                                    = "/bin/bash"
  }

  template_url       = "https://s3.amazonaws.com/CloudFormationTemplate/autoscale.json"
  capabilities       = ["CAPABILITY_IAM"]
  disable_rollback   = true
  timeout_in_minutes = 50
}
