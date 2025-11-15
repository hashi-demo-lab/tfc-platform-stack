# ============================================================================
# Identity Tokens for OIDC Authentication
# ============================================================================

# Note: TFE provider uses Stack's execution context automatically
# GitHub requires a PAT token passed via variable set

# Access variable set for GitHub token
store "varset" "platform_team_config" {
  name     = "platform_team"
  category = "terraform"
}

# ============================================================================
# Local Values
# ============================================================================

locals {
  # Common configuration
  organization        = "cloudbrokeraz"
  github_organization = "CloudbrokerAz"
  platform_project    = "Platform_Team"
  
  # Commit configuration
  commit_author_name  = "Platform Team"
  commit_author_email = "platform-team@cloudbrokeraz.com"
  
  # Repository configuration
  create_bu_repositories   = true  # Disabled: CloudbrokerAz is a user account, not an org
  bu_stack_repo_prefix     = "tfc"
  bu_stack_repo_suffix     = "bu-stack"
  enable_branch_protection = false  # Requires GitHub Pro for private repos
  
  # YAML Configuration Content - Embedded as strings (file() not available in .tfdeploy.hcl)
  finance_yaml = <<-EOT
    business_unit: finance

    bu_projects:
      - project_name: "payment-gateway"
        project_description: "Payment processing infrastructure"
      
      - project_name: "financial-reporting"
        project_description: "Financial reporting and analytics infrastructure"
  EOT
  
  engineering_yaml = <<-EOT
    business_unit: engineering

    bu_projects:
      - project_name: "platform-services"
        project_description: "Core platform services and infrastructure"
      
      - project_name: "developer-tools"
        project_description: "Developer productivity and tooling infrastructure"
      
      - project_name: "api-gateway"
        project_description: "API gateway and service mesh infrastructure"
  EOT
  
  sales_yaml = <<-EOT
    business_unit: sales

    bu_projects:
      - project_name: "crm-platform"
        project_description: "Customer relationship management platform infrastructure"
      
      - project_name: "analytics-pipeline"
        project_description: "Sales analytics and reporting pipeline"
      
      - project_name: "sales-portal"
        project_description: "Sales team portal and tools infrastructure"
  EOT
}

# ============================================================================
# Deployment: Finance BU
# ============================================================================

deployment "finance" {
  inputs = {
    # Organization
    tfc_organization_name = local.organization
    
    # Filter to finance business unit
    business_unit = "finance"
    
    # YAML Configuration - Reference local variable
    yaml_config_content = local.finance_yaml
    
    # GitHub token from variable set
    github_token = store.varset.platform_team_config.github_token
    tfe_identity_token = store.varset.platform_team_config.token
    
    # GitHub repository creation
    create_bu_repositories   = local.create_bu_repositories
    github_organization      = local.github_organization
    bu_stack_repo_prefix     = local.bu_stack_repo_prefix
    bu_stack_repo_suffix     = local.bu_stack_repo_suffix
    enable_branch_protection = local.enable_branch_protection
    
    # Platform configuration
    platform_project_name = local.platform_project
    
    # Commit author
    commit_author_name  = local.commit_author_name
    commit_author_email = local.commit_author_email
  }
  destroy = false
}

# # ============================================================================
# # Deployment: Engineering BU
# # ============================================================================

# deployment "engineering" {
#   inputs = {
#     # Organization
#     tfc_organization_name = local.organization
    
#     # Filter to engineering business unit
#     business_unit = "engineering"
    
#     # YAML Configuration - Reference local variable
#     yaml_config_content = local.engineering_yaml
    
#     # GitHub token from variable set
#     github_token = store.varset.platform_team_config.github_token
#     tfe_identity_token = store.varset.platform_team_config.token
    
#     # GitHub repository creation
#     create_bu_repositories   = local.create_bu_repositories
#     github_organization      = local.github_organization
#     bu_stack_repo_prefix     = local.bu_stack_repo_prefix
#     bu_stack_repo_suffix     = local.bu_stack_repo_suffix
#     enable_branch_protection = local.enable_branch_protection
    
#     # Platform configuration
#     platform_project_name = local.platform_project
    
#     # Commit author
#     commit_author_name  = local.commit_author_name
#     commit_author_email = local.commit_author_email
#   }
#   destroy = true
# }

# # ============================================================================
# # Deployment: Sales BU
# # ============================================================================

# deployment "sales" {
#   inputs = {
#     # Organization
#     tfc_organization_name = local.organization
    
#     # Filter to sales business unit
#     business_unit = "sales"
    
#     # YAML Configuration - Reference local variable
#     yaml_config_content = local.sales_yaml
    
#     # GitHub token from variable set
#     github_token = store.varset.platform_team_config.github_token
#     tfe_identity_token = store.varset.platform_team_config.token
    
#     # GitHub repository creation
#     create_bu_repositories   = local.create_bu_repositories
#     github_organization      = local.github_organization
#     bu_stack_repo_prefix     = local.bu_stack_repo_prefix
#     bu_stack_repo_suffix     = local.bu_stack_repo_suffix
#     enable_branch_protection = local.enable_branch_protection
    
#     # Platform configuration
#     platform_project_name = local.platform_project
    
#     # Commit author
#     commit_author_name  = local.commit_author_name
#     commit_author_email = local.commit_author_email
#   }
#   destroy = true
# }

