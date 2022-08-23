resource "aws_lb" "test" {
  name               = "Terra"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public.id]
  subnets            = [aws_subnet.private.id, aws_subnet.public.id ]
  enable_deletion_protection = false
  tags = {
    Name = "Terra"
  }
}
#TARGET GROUP  
resource "aws_lb_target_group" "tg_terraform987" {
  name     = "terra-tg1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.server1.id
}
# lISTNER
resource "aws_lb_listener" "LG" {
  load_balancer_arn = aws_lb.test.arn
  port              = "80"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_terraform987.arn
  }
}