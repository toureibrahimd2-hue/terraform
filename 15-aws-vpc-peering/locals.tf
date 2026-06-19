locals {

  tags = merge(var.tags, {
    creation_date = timestamp()
  })
}