variable "db_username" {
    description = "The username for the db"
    type        = string
    sensitive   = true

    validation {
        # 1–16 chars, starts with a letter, letters/digits/underscore only
        condition     = can(regex("^[A-Za-z][A-Za-z0-9_]{0,15}$", var.db_username))
        error_message = "db_username must be 1–16 chars, start with a letter, and contain only letters, digits, or underscore. Example: my_example_user."
    }

    validation {
        # avoid common reserved names (MySQL reserved words vary; catch the usual culprits)
        condition     = !contains(["root","mysql","admin"], lower(var.db_username))
        error_message = "db_username can't be a reserved name like root, mysql, or admin."
    }
}

variable "db_password" {
    description = "The password for the db"
    type        = string
    sensitive   = true
}