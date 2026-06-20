locals {
  users = csvdecode(file("users.csv"))
  departements = distinct([for user in local.users : user.department])

    username = {
        for user in local.users :
        user.first_name => lower("${substr(user.first_name, 0, 1)}${user.last_name}")
    }

    normalize_department = {
        for departement in local.departements :
        departement => lower(replace(departement, " ", "_"))
  }

  tags = {
    Environment = "dev"
    Project     = "terraform-iam-user-management"
    ManagedBy   = "Terraform"
    creation_date = timestamp()
  }
}