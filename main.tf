provider "aws" {
    region = "eu-north-1"
}

data "aws_vpc" "default" {
    default = true
}
data "aws_subnets" "default" {
    filter {
        name = "vpc-id"
        values = [data.aws_vpc.default.id]
    }
}
variable "server_port" {
    description     = "The port the server will use for HTTP requests"
    type            = number
    default         = 8080
}

resource "aws_launch_template" "my-example-lt" {
    name_prefix                 = "my-example-template-"
    image_id                    = "ami-042b4708b1d05f512"
    instance_type               = "t3.micro"
    monitoring {
        enabled                 = true
    }
    placement {
        availability_zone           = "eu-north-1"
    }

    vpc_security_group_ids      = [aws_security_group.instance.id]
    tag_specifications {
        resource_type           = "instance"

        tags = {
            Name                = "my-test"
        }
  }

    user_data = base64encode(<<-EOF
                #!/bin/bash
                echo "Hello, World" > index.html
                nohup busybox httpd -f -p ${var.server_port} &
                EOF
    )
}

resource "aws_autoscaling_group" "my-example-asg" {
    name               = "example-asg"
    launch_template {
        id              = aws_launch_template.my-example-lt.id
        version         = "$Latest"
    }

    vpc_zone_identifier = data.aws_subnets.default.ids
    target_group_arns   = [aws_lb_target_group.asg.arn]
    health_check_type   = "ELB"

    min_size            = 2
    max_size            = 10
    tag {
        key = "Name"
        value = "terraform-asg-example"
        propagate_at_launch = true
}
}

resource "aws_lb" "my-lb-example" {
    name                = "terraform-asg-example"
    load_balancer_type  = "application"
    subnets             = data.aws_subnets.default.ids
    security_groups     = [aws_security_group.alb.id]
}           

resource "aws_lb_listener" "http" {
    load_balancer_arn   = aws_lb.my-lb-example.arn
    port                = 80
    protocol            = "HTTP"
    default_action {
      type = "fixed-response"

      fixed_response {
        content_type    = "text/plain"
        message_body    = "404: page not found"
        status_code     = 404
      }
    }
}

resource "aws_lb_listener_rule" "asg" {
    listener_arn    = aws_lb_listener.http.arn
    priority        = 100

    condition {
      path_pattern {
        values = ["*"]
      }
    }

    action {
      type              = "forward"
      target_group_arn  = aws_lb_target_group.asg.arn
    }
}

resource "aws_security_group" "alb" {
    name = "terraform-example-alb"

  # Allow inbound HTTP requests
    ingress {
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"] 
    }

    # Allow all outbound requests
    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"] 
    }
}

resource "aws_lb_target_group" "asg" {
    name        = "terraform-asg-example"
    port        = var.server_port
    protocol    = "HTTP"
    vpc_id      = data.aws_vpc.default.id

    health_check {
      path                  = "/"
      protocol              = "HTTP"
      matcher               = "200"
      interval              = 15
      timeout               = 3
      healthy_threshold     = 2
      unhealthy_threshold   = 2
    }
}

resource "aws_security_group" "instance" {
    name = "terraform-my-example"
    ingress {
        from_port   = var.server_port
        to_port     = var.server_port
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

output "alb_dns_name" {
    value       = aws_lb.my-lb-example.dns_name
    description = "The domain name of the load balancer"
}