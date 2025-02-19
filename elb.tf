# target group
resource "aws_lb_target_group" "sharkconservation-tg" {
  name        = "sharkconservation-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.shark_conservation_vpc.id

  tags = {
    name = "shark-conservation"
  }

  health_check {
    enabled             = true
    interval            = 10
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# creating ALB
resource "aws_lb" "sharkconservation-application-lb" {
  name               = "sharkconservation-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_vpc.shark_conservation_vpc.id, aws_vpc.shark_conservation_vpc.id]
  security_groups    = [aws_vpc.shark_conservation_vpc.id]
  ip_address_type    = "ipv4"

  tags = {
    name = "shark-conservation"
  }
}

resource "aws_lb_listener" "shark-conservation-alb-listener" {
  load_balancer_arn = aws_lb.sharkconservation-application-lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.sharkconservation-tg.arn
  }
}

resource "aws_lb_target_group_attachment" "sharkconservation-ec2-attach" {
  count            = length(aws_instance.instance)
  target_group_arn = aws_lb_target_group.sharkconservation-tg.arn
  target_id        = aws_instance.instance[count.index].id
}
