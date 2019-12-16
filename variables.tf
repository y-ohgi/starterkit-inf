locals {
  workspaces = {
    default = local.stg
    stg     = local.stg
    prd     = local.prd
  }

  workspace = local.workspaces[terraform.workspace]

  name = "${terraform.workspace}-myapp"

  tags = {
    Terraform   = "true"
    Environment = terraform.workspace
  }
}
