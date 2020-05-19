data "aws_route53_zone" "selected" {
  name = var.r53zone
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "${var.externaldnshost}.${var.r53zone}"
  type    = "A"
  alias {
    name                   = aws_lb.external_nlb.dns_name
    zone_id                = aws_lb.external_nlb.zone_id
    evaluate_target_health = true
  }
}

data "aws_route53_zone" "selectedapp" {
  name = var.r53zone
}

/*
resource "aws_route53_record" "app" {
  zone_id = "${data.aws_route53_zone.selectedapp.zone_id}"
  name    = "${var.externaldnshostapp}.${var.r53zone}"
  type    = "A"
  alias {
    name                   = "${aws_lb.external_nlb2.dns_name}"
    zone_id                = "${aws_lb.external_nlb2.zone_id}"
    evaluate_target_health = true
  }
}
*/
data "aws_route53_zone" "selectedalb" {
  name = var.r53zone
}

resource "aws_route53_record" "alb" {
  zone_id = data.aws_route53_zone.selectedapp.zone_id
  name    = "${var.externaldnshostalb}.${var.r53zone}"
  type    = "A"
  alias {
    name                   = aws_lb.external_alb.dns_name
    zone_id                = aws_lb.external_alb.zone_id
    evaluate_target_health = true
  }
}

