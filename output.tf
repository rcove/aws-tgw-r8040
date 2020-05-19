##########################################
############# Outputs  ###################
##########################################
/*
output "vmss_public_ip" {
    value = "${azurerm_public_ip.external_alb.fqdn}"
	description = "The FQDN of the Frontend Application load balancer."
}


output "jumphost_ip_address" {
	value = "${azurerm_public_ip.pub1.ip_address}"
	description = "The public IP address of the jumphost server instance."
}
*/
