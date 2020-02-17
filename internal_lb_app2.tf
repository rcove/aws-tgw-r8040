# Deploy internal LB for app2
resource "aws_lb" "internal_aws_lb_app2" {
  name               = "${var.project_name}-Internal-NLB-app2"
  internal           = true
  load_balancer_type = "network"
  subnets            = ["${aws_subnet.spoke_1a_external_subnet.*.id}"]

  tags = {
    Environment       = "${var.project_name}-Internal_NLB_app2"
    x-chkp-forwarding = "TCP-${var.app_2_high_port}-80"
    x-chkp-management = "${var.template_management_server_name}"
    x-chkp-template   = "${var.inbound_configuration_template_name}"
  }
} 


resource "aws_lb_listener" "internal_lb_listener_app2" {  
  load_balancer_arn = "${aws_lb.internal_aws_lb_app2.arn}"  
  port              = 80  
  protocol          = "TCP"
  
  default_action {    
    target_group_arn = "${aws_lb_target_group.internal_lb_target_group_app2.arn}"
    type             = "forward"  
  }
} 

resource "aws_lb_target_group" "internal_lb_target_group_app2" {   
  name = "${var.project_name}-Int-NLB-TG-app2" 
  port     = "80"  
  protocol = "TCP"  
  vpc_id   = "${aws_vpc.spoke_1a_vpc.id}"   
  tags {    
    name = "${var.project_name}-Int-NLB-TG-app2"    
  }     
} 
resource "aws_lb_target_group_attachment" "internal_lb_target_group_attachment_app2" {
  count            = "${aws_instance.spoke_1a_instance.count}"
  target_group_arn = "${aws_lb_target_group.internal_lb_target_group_app2.arn}"
  target_id        = "${element(aws_instance.spoke_1a_instance.*.id, count.index)}"
  port             = 80
}
