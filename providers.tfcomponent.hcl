# ============================================================================
# Required Providers
# ============================================================================

required_providers {
  tfe = {
    source  = "hashicorp/tfe"
    version = "~> 0.60"
  }
  github = {
    source  = "integrations/github"
    version = "~> 6.0"
  }
}

# ============================================================================
# TFE Provider - Uses Stack Execution Context Automatically
# ============================================================================

provider "tfe" "this" {
  config {
    hostname = "app.terraform.io"
    token = var.tfe_identity_token
  }
}

# ============================================================================
# GitHub Provider
# ============================================================================

provider "github" "this" {
  config {
    owner = var.github_organization
    token = var.github_token  # Passed from deployment via variable set
  }
}
