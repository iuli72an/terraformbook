provider "aws" {
    region = "eu-north-1"
}

resource "aws_db_instance" "my-db-example" {
    identifier_prefix   = "terraform-up-and-running"
    engine               = "mysql"
    allocated_storage    = 10
    instance_class       = "db.t3.micro"
    skip_final_snapshot  = true
    db_name              = "example_databaseb"
    username             = var.db_username
    password             = var.db_password
}

terraform {
   backend "s3" {
    bucket         = "terraform-up-and-running-state-iulian-devops"
    key            = "stage/data-stores/mysql/terraform.tfstate"
    region         = "eu-north-1"
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true

  }
}