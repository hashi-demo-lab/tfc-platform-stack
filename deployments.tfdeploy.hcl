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
  github_organization = "hashi-demo-lab"
  platform_project    = "Platform_Team"
  
  # Commit configuration
  commit_author_name  = "Platform Team"
  commit_author_email = "platform-team@cloudbrokeraz.com"
  
  # Repository configuration
  create_bu_repositories   = true
  bu_stack_repo_prefix     = "tfc"
  bu_stack_repo_suffix     = "bu-stack"
  enable_branch_protection = false  # Requires GitHub Pro for private repos
  
  # HCP Terraform Stack configuration
  create_hcp_stacks = true  # Enable Stack creation for BU repos
  
  # VCS OAuth Token ID for Stack-GitHub connection
  # Get from: HCP Terraform → Organization Settings → Version Control → Providers
  # Format: ot-xxxxxxxxxxxxx
  vcs_oauth_token_id = "ot-JKCe2joSPQz55gbq"  # Replace with your OAuth token ID
  
  # YAML Configuration Content - Embedded as strings (file() not available in .tfdeploy.hcl)
  platform_engineering_yaml = <<-EOT
    business_unit: platform-engineering

    bu_projects:
      - project_name: kubernetes-platform
        project_description: Kubernetes cluster management and operations
        var_sets:
          variables:
            - key: environment
              value: production
              description: Deployment environment
            - key: team
              value: platform-k8s
            - key: aws_region
              value: us-east-1
            - key: cluster_version
              value: "1.28"
              description: Kubernetes version
              sensitive: false

      - project_name: service-mesh
        project_description: Service mesh infrastructure and observability
        var_sets:
          variables:
            - key: environment
              value: production
            - key: team
              value: platform-mesh
            - key: mesh_type
              value: istio
              description: Service mesh implementation
            - key: enable_tracing
              value: "true"
              hcl: true

      - project_name: ci-cd-platform
        project_description: CI/CD pipeline infrastructure and tooling
        var_sets:
          variables:
            - key: environment
              value: production
            - key: team
              value: platform-cicd
            - key: aws_region
              value: us-west-2
            - key: enable_artifact_scanning
              value: "true"
              hcl: true
  EOT
  
  security_ops_yaml = <<-EOT
    business_unit: security-ops

    bu_projects:
      - project_name: siem-platform
        project_description: Security Information and Event Management infrastructure
        var_sets:
          variables:
            - key: environment
              value: production
            - key: team
              value: secops-siem
            - key: aws_region
              value: us-east-1
            - key: retention_days
              value: "365"
              description: Log retention period
            - key: enable_threat_detection
              value: "true"
              hcl: true

      - project_name: vulnerability-scanning
        project_description: Vulnerability scanning and compliance monitoring
        var_sets:
          variables:
            - key: environment
              value: shared
            - key: team
              value: secops-vuln
            - key: scan_frequency
              value: daily
            - key: enable_auto_remediation
              value: "false"
              hcl: true
            - key: severity_threshold
              value: '["critical", "high"]'
              hcl: true
              description: Alert on these severity levels

      - project_name: identity-access-management
        project_description: IAM and identity governance infrastructure
        var_sets:
          variables:
            - key: environment
              value: production
            - key: team
              value: secops-iam
            - key: aws_region
              value: us-east-1
            - key: mfa_required
              value: "true"
              hcl: true
            - key: session_duration_hours
              value: "8"
              description: Maximum session duration

      - project_name: secrets-management
        project_description: Secrets and certificate management infrastructure
        var_sets:
          variables:
            - key: environment
              value: production
            - key: team
              value: secops-secrets
            - key: aws_region
              value: us-west-2
            - key: rotation_enabled
              value: "true"
              hcl: true
            - key: rotation_days
              value: "90"
              description: Secret rotation period
  EOT
  
  cloud_infrastructure_yaml = <<-EOT
    business_unit: cloud-infrastructure

    bu_projects:
      - project_name: network-backbone
        project_description: Core network infrastructure and connectivity
        var_sets:
          variables:
            - key: environment
              value: production
            - key: team
              value: cloudinfra-network
            - key: aws_region
              value: us-east-1
            - key: vpc_cidr
              value: 10.0.0.0/16
              description: Primary VPC CIDR block
            - key: enable_transit_gateway
              value: "true"
              hcl: true
            - key: availability_zones
              value: "3"

      - project_name: compute-resources
        project_description: VM and container compute infrastructure
        var_sets:
          variables:
            - key: environment
              value: production
            - key: team
              value: cloudinfra-compute
            - key: aws_region
              value: us-west-2
            - key: enable_autoscaling
              value: "true"
              hcl: true
            - key: enable_spot_instances
              value: "true"
              hcl: true
            - key: cost_optimization_level
              value: balanced
              description: Cost optimization strategy

      - project_name: storage-services
        project_description: Object storage and backup infrastructure
        var_sets:
          variables:
            - key: environment
              value: production
            - key: team
              value: cloudinfra-storage
            - key: aws_region
              value: us-east-1
            - key: lifecycle_enabled
              value: "true"
              hcl: true
            - key: backup_retention_days
              value: "90"
              description: Backup retention period

      - project_name: disaster-recovery
        project_description: DR and business continuity infrastructure
        var_sets:
          variables:
            - key: environment
              value: production
            - key: team
              value: cloudinfra-dr
            - key: primary_region
              value: us-east-1
            - key: dr_region
              value: us-west-2
            - key: rpo_minutes
              value: "60"
              description: Recovery Point Objective
            - key: rto_minutes
              value: "240"
              description: Recovery Time Objective
  EOT
}

# ============================================================================
# Deployment: Platform Engineering Team
# ============================================================================

deployment "platform-engineering" {
  inputs = {
    # Organization
    tfc_organization_name = local.organization
    
    # Filter to platform-engineering business unit
    business_unit = "platform-engineering"
    
    # YAML Configuration - Reference local variable
    yaml_config_content = local.platform_engineering_yaml
    
    # GitHub token from variable set
    github_token = store.varset.platform_team_config.github_token
    tfe_identity_token = store.varset.platform_team_config.token
    
    # GitHub repository creation
    create_bu_repositories   = local.create_bu_repositories
    github_organization      = local.github_organization
    bu_stack_repo_prefix     = local.bu_stack_repo_prefix
    bu_stack_repo_suffix     = local.bu_stack_repo_suffix
    enable_branch_protection = local.enable_branch_protection
    
    # HCP Terraform Stack creation
    create_hcp_stacks  = local.create_hcp_stacks
    vcs_oauth_token_id = local.vcs_oauth_token_id
    
    # Platform configuration
    platform_project_name = local.platform_project
    
    # Commit author
    commit_author_name  = local.commit_author_name
    commit_author_email = local.commit_author_email
  }
  destroy = false
}

# ============================================================================
# Deployment: Security Operations Team
# ============================================================================

deployment "security-ops" {
  inputs = {
    # Organization
    tfc_organization_name = local.organization
    
    # Filter to security-ops business unit
    business_unit = "security-ops"
    
    # YAML Configuration - Reference local variable
    yaml_config_content = local.security_ops_yaml
    
    # GitHub token from variable set
    github_token = store.varset.platform_team_config.github_token
    tfe_identity_token = store.varset.platform_team_config.token
    
    # GitHub repository creation
    create_bu_repositories   = local.create_bu_repositories
    github_organization      = local.github_organization
    bu_stack_repo_prefix     = local.bu_stack_repo_prefix
    bu_stack_repo_suffix     = local.bu_stack_repo_suffix
    enable_branch_protection = local.enable_branch_protection
    
    # HCP Terraform Stack creation
    create_hcp_stacks  = local.create_hcp_stacks
    vcs_oauth_token_id = local.vcs_oauth_token_id
    
    # Platform configuration
    platform_project_name = local.platform_project
    
    # Commit author
    commit_author_name  = local.commit_author_name
    commit_author_email = local.commit_author_email
  }
  destroy = false
}

# ============================================================================
# Deployment: Cloud Infrastructure Team
# ============================================================================

deployment "cloud-infrastructure" {
  inputs = {
    # Organization
    tfc_organization_name = local.organization
    
    # Filter to cloud-infrastructure business unit
    business_unit = "cloud-infrastructure"
    
    # YAML Configuration - Reference local variable
    yaml_config_content = local.cloud_infrastructure_yaml
    
    # GitHub token from variable set
    github_token = store.varset.platform_team_config.github_token
    tfe_identity_token = store.varset.platform_team_config.token
    
    # GitHub repository creation
    create_bu_repositories   = local.create_bu_repositories
    github_organization      = local.github_organization
    bu_stack_repo_prefix     = local.bu_stack_repo_prefix
    bu_stack_repo_suffix     = local.bu_stack_repo_suffix
    enable_branch_protection = local.enable_branch_protection
    
    # HCP Terraform Stack creation
    create_hcp_stacks  = local.create_hcp_stacks
    vcs_oauth_token_id = local.vcs_oauth_token_id
    
    # Platform configuration
    platform_project_name = local.platform_project
    
    # Commit author
    commit_author_name  = local.commit_author_name
    commit_author_email = local.commit_author_email
  }
  destroy = false
}

