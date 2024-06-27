#-------------------------------------------------------------------------------------
# Create users
#-------------------------------------------------------------------------------------
# Create users
resource "aws_iam_user" "user" {
  count         = var.user_number
  name          = "${var.prefix}-${var.region}-user-${count.index + 1}"
  path          = var.user_path_prefix
  force_destroy = true

  tags = var.tags
}
# Create group membership to each user
resource "aws_iam_user_group_membership" "user_group" {
  count = var.user_number
  user  = aws_iam_user.user[count.index].name

  groups = [var.group_name]
}
# Create login console profile
resource "aws_iam_user_login_profile" "user_login-profile" {
  count = var.user_number
  user  = aws_iam_user.user[count.index].name
}
# Create an Access-Keys for user
resource "aws_iam_access_key" "user_access_key" {
  count = var.user_number
  user  = aws_iam_user.user[count.index].name
}
