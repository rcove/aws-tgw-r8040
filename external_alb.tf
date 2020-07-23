# -------------------------------------------
# Create an External ALB for the applications 
# -------------------------------------------
# Security group for alb
resource "aws_security_group" "ealb" {
  name        = "${var.project_name}-Ext-LB-SG"
  description = "load balancer security group"
  vpc_id      = aws_vpc.inbound_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.project_name}-Ext-LB-SG"
  }
}

# Application Load Balancer 
resource "aws_lb" "external_alb" {
  name               = "${var.project_name}-External-ALB"
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.inbound_subnet.*.id
  security_groups    = [aws_security_group.ealb.id]
  tags = {
    name = "${var.project_name}-External-ALB"
  }
}

resource "aws_lb_target_group" "external_lb_tg_app1" {
  name     = "${var.project_name}-Ext-ALB-TG-app1"
  port     = var.app_1_high_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.inbound_vpc.id
  tags = {
    name = "${var.project_name}-Ext-ALB-TG-app1"
  }

  # Alter the destination of the health check to be the login page.
  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_target_group" "external_lb_tg_app2" {
  name     = "${var.project_name}-Ext-ALB-TG-app2"
  port     = var.app_2_high_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.inbound_vpc.id
  tags = {
    name = "${var.project_name}-Ext-ALB-TG-app2"
  }

  # Alter the destination of the health check to be the login page.
  health_check {
    path = "/"
    port = "traffic-port"
  }
}

resource "aws_lb_listener" "external_alb_listener" {
  load_balancer_arn = aws_lb.external_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.external_lb_tg_app1.arn
    type             = "forward"
  }
}

resource "aws_lb_listener_rule" "external_alb_rules" {
  listener_arn = aws_lb_listener.external_alb_listener.arn

  priority = 90

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.external_lb_tg_app2.arn
  }
    condition {
    path_pattern {
      values = ["/app2/*"]
    }
  }
/*

  #### Terrform does not allow for multiple ALB rules but you can add this one after the build
  #### posibly it is a bug in tf 0.11.x not tested yet in tf 0.12.x  

  priority     = 100

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.external_lb_tg_app1.arn}"
  }
  # note this form of condition (the non deprectiated one) does not work for some reasonn 
  condition {
    path-pattern {
    values = ["/app1/*"]
    }
   }
*/
}

# The attachment needs to be done after creation as it is in the CFT 
# should be able to fix by using the CFT to create the ALB - to do
/*
resource "aws_lb_target_group_attachment" "external_alb_target_group_attachment_app2" {
  count            = "${aws_instance.xxxxx.count}"
  target_group_arn = "${aws_lb_target_group.external_lb_tg_app2.arn}"
  target_id        = "${element(aws_instance.-.*.id, count.index)}"
  port             = ${var.app_1_high_port}
}
*/
