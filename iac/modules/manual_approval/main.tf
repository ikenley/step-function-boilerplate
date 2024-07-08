#-------------------------------------------------------------------------------
# Main local configuration
#-------------------------------------------------------------------------------

data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id

  id            = "${var.namespace}-${var.env}-step-demo"
  output_prefix = "/${var.namespace}/${var.env}/step-demo"

  tags = merge(var.tags, {
    Terraform   = true
    Environment = var.env
    is_prod     = var.is_prod
  })
}
