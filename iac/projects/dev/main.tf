# ------------------------------------------------------------------------------
# step-demo
# Example of AWS Step Function with various integrations
# ------------------------------------------------------------------------------

terraform {
  required_version = ">= 0.14"

  backend "s3" {
    profile = "terraform-dev"
    region  = "us-east-1"
    bucket  = "924586450630-terraform-state"
    key     = "step-function-boilerplate/dev/terraform.tfstate.json"
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "terraform-dev"
}

# ------------------------------------------------------------------------------
# Resources
# ------------------------------------------------------------------------------

module "main" {
  source = "../../modules/main"

  namespace    = "ik"
  env          = "dev"
  is_prod      = false

  # git_repo   = "ikenley/ai-app"
  # git_branch = "image" #"main"

}
