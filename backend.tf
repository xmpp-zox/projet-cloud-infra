############################
# Backend: ALB + TG + Launch Template + ASG
############################

# --- ALB in public subnets ---
resource "aws_lb" "app" {
  name               = "${var.project}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.public[*].id

  tags = { Name = "${var.project}-alb" }
}

resource "aws_lb_target_group" "backend" {
  name        = "${var.project}-tg"
  port        = var.backend_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/health"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = { Name = "${var.project}-tg" }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}

# --- Launch Template ---
resource "aws_launch_template" "backend" {
  name_prefix   = "${var.project}-lt-"
  image_id      = data.aws_ami.al2023.id
  instance_type = var.instance_type
  key_name      = var.key_name == "" ? null : var.key_name

  vpc_security_group_ids = [aws_security_group.backend.id]

  user_data = base64encode(templatefile("${path.module}/user_data/backend.sh.tftpl", {
    backend_repo = var.backend_repo
    db_host      = aws_db_instance.mysql.address
    db_user      = var.db_username
    db_password  = var.db_password
    db_name      = var.db_name
    backend_port = var.backend_port
  }))

  tag_specifications {
    resource_type = "instance"
    tags          = { Name = "${var.project}-backend" }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# --- ASG across the two private subnets ---
resource "aws_autoscaling_group" "backend" {
  name                      = "${var.project}-asg"
  min_size                  = 2
  desired_capacity          = 2
  max_size                  = 4
  vpc_zone_identifier       = aws_subnet.private[*].id
  target_group_arns         = [aws_lb_target_group.backend.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 180

  launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project}-backend"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}

# --- Target tracking: scale on average CPU > 70% ---
resource "aws_autoscaling_policy" "cpu_tt" {
  name                   = "${var.project}-cpu-tt"
  autoscaling_group_name = aws_autoscaling_group.backend.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 70.0
  }
}
