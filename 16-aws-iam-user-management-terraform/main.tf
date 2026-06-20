resource "aws_iam_user" "users" {
    for_each = {for user in local.users : user.first_name => user}

    name = local.username[each.key]
    path = "/users/${local.normalize_department[each.value.department]}/"

    tags= merge(local.tags, {
 
    display_name = "${each.value.first_name} ${each.value.last_name}"
    })
}

resource "aws_iam_user_login_profile" "user_login_profile" {
  for_each = aws_iam_user.users

  user    = each.value.name
  password_reset_required = true

  lifecycle {
    ignore_changes = [
      password_length,
      password_reset_required,
      pgp_key,
    ]
  }
  }

resource "aws_iam_group" "groups" {
  for_each = toset(local.departements)
  name = local.normalize_department[each.value]
  path = "/groups/${local.normalize_department[each.value]}/"
 
}

resource "aws_iam_group_membership" "group_members" {
  
  for_each = aws_iam_group.groups
  name = "${each.value.name}-membership"
  group = each.value.name

  users = [
    for user in local.users:
    # lower("${substr(user.first_name, 0, 1)}${user.last_name}") 
    local.username[user.first_name]
    if  local.normalize_department[user.department] == local.normalize_department[each.key]
      ]

  depends_on = [ aws_iam_user.users, aws_iam_group.groups ]
}