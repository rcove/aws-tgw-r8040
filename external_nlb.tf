# Deploy external NLB
resource "aws_lb" "external_nlb" {
  name               = "${var.project_name}-External-NLB"
  internal           = false
  load_balancer_type = "network"
  subnets            = aws_subnet.inbound_subnet.*.id

  tags = {
    name = "${var.project_name}-External-NLB"
  }
}

resource "aws_lb_listener" "external_lb_listener" {
  load_balancer_arn = aws_lb.external_nlb.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.external_lb_target_group.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "external_lb_target_group" {
  name     = "${var.project_name}-Ext-NLB-TG"
  port     = var.app_1_high_port
  protocol = "TCP"
  vpc_id   = aws_vpc.inbound_vpc.id
  tags = {
    name = "${var.project_name}-Ext-NLB-TG"
  }
}

# Deploy external NLB2
resource "aws_lb" "external_nlb2" {
  name               = "${var.project_name}-External-NLB2"
  internal           = false
  load_balancer_type = "network"
  subnets            = aws_subnet.inbound_subnet.*.id

  tags = {
    name = "${var.project_name}-External-NLB2"
  }
}

resource "aws_lb_listener" "external_lb_listener2" {
  load_balancer_arn = aws_lb.external_nlb2.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    target_group_arn = aws_lb_target_group.external_lb2_target_group.arn
    type             = "forward"
  }
}

resource "aws_lb_target_group" "external_lb2_target_group" {
  name     = "${var.project_name}-Ext-NLB2-TG"
  port     = var.app_2_high_port
  protocol = "TCP"
  vpc_id   = aws_vpc.inbound_vpc.id
  tags = {
    name = "${var.project_name}-Ext-NLB2-TG"
  }
}

