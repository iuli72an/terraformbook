provider "aws" {
    region = "eu-north-1"
}

variable "server_port" {
    description     = "The port the server will use for HTTP requests"
    type            = number
    default         = 8080
}
resource "aws_instance" "my-example" {
    ami             = "ami-042b4708b1d05f512"
    instance_type   = "t3.micro"
    vpc_security_group_ids = [aws_security_group.terraform-my-example-sg.id]
    user_data = <<-EOF
                #!/bin/bash
                echo "Hello, World" > index.html
                nohup busybox httpd -f -p ${var.server_port} &
                EOF

    user_data_replace_on_change = true
    tags = {
        Name = "terraform-my-example"
    }
}
resource "aws_security_group" "terraform-my-example-sg" {
    name = "terraform-my-example-sg"
    ingress {
        from_port   = var.server_port
        to_port     = var.server_port
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}