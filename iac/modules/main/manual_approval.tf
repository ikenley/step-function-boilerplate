#-------------------------------------------------------------------------------
# Manual Approval step
#-------------------------------------------------------------------------------

module "manual_approval" {
  source = "../manual_approval"

  namespace    = var.namespace
  env          = var.env
  is_prod      = var.is_prod

  email = var.ses_email_address

}