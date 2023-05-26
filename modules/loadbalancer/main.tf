resource "aws_lb" "public_load_balancer" {
  name               = "public-lb-tf"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.public_lb_sg.id]
  subnets            = [var.az1_public_subnet_id,var.az2_public_subnet_id]
  enable_deletion_protection = false
  tags = {
    Name = "${terraform.workspace}-public-load-balancer"
  }
}

resource "aws_security_group" "public_lb_sg" {
  vpc_id = var.vpc_id
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
  tags = {
    Name = "${terraform.workspace}-public-lb-sg"
  }
}

resource "aws_lb_target_group" "public_load_balancer_target_group" {
  name     = "public-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path = "/"
  }
}

resource "aws_lb_target_group_attachment" "public_target_group_attachment_1" {
  target_group_arn = aws_lb_target_group.public_load_balancer_target_group.arn
  target_id        = var.az1_public_instance_id
  port             = 80
}

resource "aws_lb_target_group_attachment" "public_target_group_attachment_2" {
  target_group_arn = aws_lb_target_group.public_load_balancer_target_group.arn
  target_id        = var.az2_public_instance_id
  port             = 80
}

resource "aws_lb_listener" "public_load_balancer_listener" {
  load_balancer_arn = aws_lb.public_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public_load_balancer_target_group.arn
  }
}
/*
resource "aws_lb_listener_rule" "public_load_balancer_listener_rule" {
  listener_arn = aws_lb_listener.public_load_balancer_listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.public_load_balancer_target_group.arn
  }

  condition {
    path_pattern {
      values = ["/"]
    }
  }
}*/

resource "aws_lb" "private_load_balancer" {
  name               = "private-lb-tf"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.private_lb_sg.id]
  subnets            = [var.az1_private_subnet_id,var.az2_private_subnet_id]
  enable_deletion_protection = false
  tags = {
    Name = "${terraform.workspace}-private-load-balancer"
  }
}

resource "aws_security_group" "private_lb_sg" {
  vpc_id = var.vpc_id
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [var.nginx_sg_id]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
  tags = {
    Name = "${terraform.workspace}-private-lb-sg"
  }
}

resource "aws_lb_target_group" "private_load_balancer_target_group" {
  name     = "private-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path = "/"
  }
}

resource "aws_lb_target_group_attachment" "private_target_group_attachment_1" {
  target_group_arn = aws_lb_target_group.private_load_balancer_target_group.arn
  target_id        = var.az1_private_instance_id
  port             = 80
}

resource "aws_lb_target_group_attachment" "private_target_group_attachment_2" {
  target_group_arn = aws_lb_target_group.private_load_balancer_target_group.arn
  target_id        = var.az2_private_instance_id
  port             = 80
}

resource "aws_lb_listener" "private_load_balancer_listener" {
  load_balancer_arn = aws_lb.private_load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.private_load_balancer_target_group.arn
  }
}

