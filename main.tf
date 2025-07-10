provider "aws" {
    region = "eu-north-1"
}

resource "aws_instance" "my-example" {
    ami             = "ami-0becc523130ac9d5d"
    instance_type   = "t3.micro"
    tags = {
        Name = "terraform-my-example"
    }
}