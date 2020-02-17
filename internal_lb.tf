# Deploy internal LB
resource "aws_lb" "internal_aws_lb" {
  name               = "${var.project_name}-Internal-NLB"
  internal           = true
  load_balancer_type = "network"
  subnets            = ["${aws_subnet.spoke_1_external_subnet.*.id}"]

  tags = {
    Environment       = "${var.project_name}-Internal_NLB"
    x-chkp-forwarding = "TCP-${var.app_1_high_port}-80"
    x-chkp-management = "${var.template_management_server_name}"
    x-chkp-template   = "${var.inbound_configuration_template_name}"
  }
} 


resource "aws_lb_listener" "internal_lb_listener" {  
  load_balancer_arn = "${aws_lb.internal_aws_lb.arn}"  
  port              = 80  
  protocol          = "TCP"
  
  default_action {    
    target_group_arn = "${aws_lb_target_group.internal_lb_target_group.arn}"
    type             = "forward"  
  }
} 

resource "aws_lb_target_group" "internal_lb_target_group" {   
  name = "${var.project_name}-Int-NLB-TG" 
  port     = "80"  
  protocol = "TCP"  
  vpc_id   = "${aws_vpc.spoke_1_vpc.id}"   
  tags {    
    name = "${var.project_name}-Int-NLB-TG"    
  }     
} 

resource "aws_lb_target_group_attachment" "internal_lb_target_group_attachment" {
  count            = "${aws_instance.spoke_1_instance.count}"
  target_group_arn = "${aws_lb_target_group.internal_lb_target_group.arn}"
  target_id        = "${element(aws_instance.spoke_1_instance.*.id, count.index)}"
  port             = 80
}
