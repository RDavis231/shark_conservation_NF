# Target Group
resource "aws_lb_target_group" "shark-target-group" {
  name        = "shark-blog-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.shark_vpc.id

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

# Creating ALB
resource "aws_lb" "shark-application-lb" {
  name               = "shark-blog-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = [aws_subnet.public-1.id, aws_subnet.public-2.id]
  security_groups    = [aws_security_group.sg_vpc.id]
  ip_address_type    = "ipv4"

  tags = {
    name = "shark-conservation"
  }
}

resource "aws_lb_listener" "shark-alb-listener" {
  load_balancer_arn = aws_lb.shark-application-lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.shark-target-group.arn
  }
}

resource "aws_lb_target_group_attachment" "shark-ec2-attach" {
  count            = length(aws_instance.instance)
  target_group_arn = aws_lb_target_group.shark-target-group.arn
  target_id        = aws_instance.instance[count.index].id
}
