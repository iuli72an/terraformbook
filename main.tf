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
    min_size            = 2
    max_size            = 10
    tag {
        key = "Name"
        value = "terraform-asg-example"
        propagate_at_launch = true
}
}


# resource "aws_instance" "my-example" {
#     ami             = "ami-042b4708b1d05f512"
#     instance_type   = "t3.micro"
#     vpc_security_group_ids = [aws_security_group.instance.id]
#     user_data = <<-EOF
#                 #!/bin/bash
#                 echo "Hello, World" > index.html
#                 nohup busybox httpd -f -p ${var.server_port} &
#                 EOF

#     user_data_replace_on_change = true
#     tags = {
#         Name = "terraform-my-example"
#     }
# }
resource "aws_security_group" "instance" {
    name = "terraform-my-example"
    ingress {
        from_port   = var.server_port
        to_port     = var.server_port
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# output "public_ip" {
#     value = aws_instance.my-example.public_ip
#     description = "The public IP address of the web server"
# }