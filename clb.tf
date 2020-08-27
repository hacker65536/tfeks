resource "aws_security_group" "external-lb" {
  name        = "cluster-update-external-lb"
  description = "cluster update for external access"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_elb" "clb" {
  //availability_zones = data.aws_availability_zones.available.names

  connection_draining         = true
  connection_draining_timeout = 300
  cross_zone_load_balancing   = true
  idle_timeout                = 60
  name                        = "cluster-update-clb"
  security_groups = [
    aws_security_group.external-lb.id,
  ]
  subnets = module.vpc.public_subnets

  tags = {
    "Env" = "okrclusterupdate"
  }

  health_check {
    healthy_threshold   = 10
    interval            = 30
    target              = "HTTP:30002/"
    timeout             = 5
    unhealthy_threshold = 2
  }

  listener {
    instance_port     = 30002
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
}

