# ============================================================================
# Stack Input Variables
# ============================================================================

variable "tfc_organization_name" {
  type        = string
  description = "HCP Terraform organization name"
  default     = "cloudbrokeraz"
}

variable "github_organization" {
  type        = string
  description = "GitHub organization name"
  default     = "hashi-demo-lab"
}

variable "platform_project_name" {
  type        = string
  description = "Platform team project name in HCP Terraform"
  default     = "Platform_Team"
}

variable "platform_stack_project_id" {
  type        = string
  description = "HCP Terraform project ID where BU Stacks will be created (required due to Stacks RBAC limitation - publish_output only works within same project)"
}

variable "tfe_identity_token" {
  type        = string
  description = "OIDC identity token for TFE provider authentication"
  ephemeral   = true
  sensitive   = true
}

variable "github_token" {
  type        = string
  description = "GitHub personal access token for GitHub provider"
  ephemeral   = true
  sensitive   = true
}

# ============================================================================
# GitHub Repository Configuration
# ============================================================================

variable "create_bu_repositories" {
  type        = bool
  description = "Create GitHub repositories for BU Stacks"
  default     = true
}

variable "bu_stack_repo_prefix" {
  type        = string
  description = "Prefix for BU Stack repository names"
  default     = "tfc"
}

variable "bu_stack_repo_suffix" {
  type        = string
  description = "Suffix for BU Stack repository names"
  default     = "bu-stack"
}

variable "enable_branch_protection" {
  type        = bool
  description = "Enable branch protection on main branch"
  default     = true
}

# ============================================================================
# HCP Terraform Stack Configuration
# ============================================================================

variable "create_hcp_stacks" {
  type        = bool
  description = "Create HCP Terraform Stacks for each BU (connects to GitHub repos)"
  default     = true
}

variable "vcs_oauth_token_id" {
  type        = string
  description = "OAuth token ID for VCS connection (format: ot-xxxxx). Required if create_hcp_stacks = true."
  sensitive   = true  # Hide in logs (but NOT ephemeral - needed for tfe_stack vcs_repo)
  default     = ""
}

# ============================================================================
# Commit Configuration
# ============================================================================

variable "commit_author_name" {
  type        = string
  description = "Git commit author name for seeded files"
  default     = "Platform Team"
}

variable "commit_author_email" {
  type        = string
  description = "Git commit author email for seeded files"
  default     = "platform-team@cloudbrokeraz.com"
}

# ============================================================================
# Business Unit Filter (Optional)
# ============================================================================

variable "business_unit" {
  type        = string
  description = "Optional: Filter to single business unit (null = all BUs from YAML)"
  default     = null
}

# ============================================================================
# YAML Configuration
# ============================================================================

variable "yaml_config_content" {
  type        = string
  description = "YAML configuration content (will be passed from deployment)"
}