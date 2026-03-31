# =============================================================================
# modules/compute/main.tf
# DAY 5:  count-based EC2 instances → replaced by ASG
# DAY 10: for_each on instance tags, dynamic ingress rules
# DAY 12: ALB + create_before_destroy lifecycle for zero-downtime deploys
#
# ZERO-DOWNTIME DEPLOY DEMO (Day 12):
#   1. Apply with ami_id = "ami-OLD"
#   2. Change ami_id = "ami-NEW" in tfvars
#   3. terraform plan — see create_before_destroy in action
#   4. terraform apply — new instances register with ALB before old ones terminate
# =============================================================================

# -----------------------------------------------------------------------------
# Launch Template — defines HOW each instance starts
# DAY 12: Changing ami_id creates a new launch template version.
#         The ASG rolling update then replaces instances one by one.
# -----------------------------------------------------------------------------
resource "aws_launch_template" "app" {
  name_prefix   = "${var.name_prefix}-lt-"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [var.app_sg_id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    # DAY 3 DEMO POINT: This script runs on every new instance at boot.
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
    echo "<h1>Hello from Terraform!</h1><p>Instance: $INSTANCE_ID</p><p>Environment: ${var.name_prefix}</p>" > /var/www/html/index.html
  EOF
  )

  # DAY 12: create_before_destroy on the launch template ensures the new
  # template exists before the old one is destroyed.
  lifecycle {
    create_before_destroy = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = "${var.name_prefix}-app"
      Day  = "Day5-Day12"
    })
  }
}

# -----------------------------------------------------------------------------
# Auto Scaling Group
# DAY 5:  Replaces the simple count-based aws_instance resources
# DAY 12: instance_refresh block triggers a rolling replace on AMI change
# -----------------------------------------------------------------------------
resource "aws_autoscaling_group" "app" {
  name                = "${var.name_prefix}-asg"
  min_size            = var.min_size
  max_size            = var.max_size
  desired_capacity    = var.desired_capacity
  vpc_zone_identifier = var.subnet_ids
  target_group_arns   = [aws_lb_target_group.app.arn]
  health_check_type   = "ELB"

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  # DAY 12: instance_refresh = rolling deploy with zero downtime
  # When the launch template changes, ASG replaces instances gradually.
  # min_healthy_percentage = 90 means at most 10% of fleet is down at once.
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 90
      instance_warmup        = 60
    }
  }

  # DAY 10: for_each equivalent for ASG tags — dynamic tag block
  dynamic "tag" {
    for_each = merge(var.tags, { Name = "${var.name_prefix}-asg-instance" })
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true # DAY 12: ensures new ASG is ready before old one gone
    ignore_changes        = [desired_capacity] # Allow autoscaling to manage desired count
  }
}

# -----------------------------------------------------------------------------
# Application Load Balancer
# DAY 12: ALB is the key to zero-downtime. Traffic shifts to healthy new
#         instances before old ones are drained and terminated.
# -----------------------------------------------------------------------------
resource "aws_lb" "app" {
  name               = "${var.name_prefix}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids

  enable_deletion_protection = false # Set true in prod!

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-alb"
    Day  = "Day12"
  })
}

resource "aws_lb_target_group" "app" {
  name     = "${var.name_prefix}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
  }

  # DAY 12: deregistration_delay = how long ALB waits for in-flight requests
  # to complete before removing an instance. 30s is enough for our demo.
  deregistration_delay = 30

  tags = merge(var.tags, { Name = "${var.name_prefix}-tg" })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}
