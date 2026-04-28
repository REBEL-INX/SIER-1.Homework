# Create local file
# https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file

resource "local_file" "favorite_food" {
  content  = "mac and cheese"
  filename = "${path.module}/favoritefood.txt"
}