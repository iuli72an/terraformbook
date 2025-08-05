output "address" {
    value = aws_db_instance.my-db-example.address
    description = "Connection at the database has this endpoint"
}

output "port" {
    value = aws_db_instance.my-db-example.port
    description = "DB listening on"
}