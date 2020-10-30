
resource "aws_ecs_cluster" "ecs-cluster" {
  name = "ecs-cluster"
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami*amazon-ecs-optimized"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  owners = ["amazon", "self"]
}

resource "aws_security_group" "ec2-private-sg" {
  name        = "allow-all-ec2"
  description = "allow all"
  vpc_id      = "${aws_vpc.awsvpc.id}"
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "lc" {
  name          = "test_ecs"
  image_id      = "${data.aws_ami.amazon_linux.id}"
  instance_type = "t2.micro"
  lifecycle {
    create_before_destroy = true
  }
  iam_instance_profile        = "${aws_iam_instance_profile.ecs-ec2-role.name}"
  key_name                    = ""
  security_groups             = [aws_security_group.ec2-private-sg.id]
  associate_public_ip_address = true
  user_data                   = <<EOF
#! /bin/bash
sudo apt-get update
sudo echo ECS_CLUSTER=ecs-cluster >> /etc/ecs/ecs.config
EOF
}

resource "aws_autoscaling_group" "asg" {
  name                      = "test-asg"
  launch_configuration      = "${aws_launch_configuration.lc.name}"
  min_size                  = 0
  max_size                  = 1
  desired_capacity          = 1
  health_check_type         = "ELB"
  health_check_grace_period = 300
  vpc_zone_identifier       = [aws_subnet.private-subnet-1.id, aws_subnet.private-subnet-2.id]

  target_group_arns     = [aws_lb_target_group.lb_target_group.arn]
  protect_from_scale_in = true
  lifecycle {
    create_before_destroy = true
  }
}
