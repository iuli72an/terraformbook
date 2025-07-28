terraform {
   backend "s3" {

    # This backend configuration is filled in automatically at test time by Terratest. If you wish to run this example
    # manually, uncomment and fill in the config below.

    bucket         = "terraform-up-and-running-state-iulian-devops"
    key            = "workspaces-example/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true

  }
}

variable "workspace" {
  default = "default"
}

locals {
  instance_type = {
    default = "t3.micro"
  }
}
provider "aws" {
  region = "eu-north-1"
}

resource "aws_instance" "example" {
  ami           = "ami-042b4708b1d05f512"

  instance_type = lookup(local.instance_type, terraform.workspace, "t3.micro")

}
