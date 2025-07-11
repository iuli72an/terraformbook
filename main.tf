provider "aws" {
    region = "eu-north-1"
}

resource "aws_instance" "my-example" {
    ami             = "ami-0becc523130ac9d5d"
    instance_type   = "t3.micro"
    vpc_security_group_ids = [aws_security_group.terraform-my-example-sg.id]
    user_data = <<-EOF
                #!/bin/bash
                echo "Hello, World" > index.html
                nohup busybox http -f -p 8080 &
                EOF

    user_data_replace_on_change = true
    tags = {
        Name = "terraform-my-example"
    }
}
resource "aws_security_group" "terraform-my-example-sg" {
    name = "terraform-my-example-sg"
    ingress {
        from_port   = 8080
        to_port     = 8080
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}