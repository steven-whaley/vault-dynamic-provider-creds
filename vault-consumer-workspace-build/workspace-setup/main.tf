# Create JWT Backend Role for Plans
resource "vault_jwt_auth_backend_role" "tfc_plan_role" {
  backend        = var.vault_workspace_variables["TFC_VAULT_AUTH_PATH"]
  role_name      = "${var.tfc_workspace_name}-vault-plan-role"
  token_policies = [vault_policy.tfc_plan_policy.name]

  bound_audiences = ["vault.workload.identity"]

  bound_claims_type = "glob"
  bound_claims = {
    sub = "organization:${var.tfc_organization_name}:project:${var.tfc_project_name}:workspace:${var.tfc_workspace_name}:run_phase:plan"
  }

  user_claim = "terraform_full_workspace"
  role_type  = "jwt"
  token_ttl  = 1200
}

# Create JWT Backend Role for Applies
resource "vault_jwt_auth_backend_role" "tfc_apply_role" {
  backend        = var.vault_workspace_variables["TFC_VAULT_AUTH_PATH"]
  role_name      = "${var.tfc_workspace_name}-vault-apply-role"
  token_policies = [vault_policy.tfc_apply_policy.name]

  bound_audiences = ["vault.workload.identity"]

  bound_claims_type = "glob"
  bound_claims = {
    sub = "organization:${var.tfc_organization_name}:project:${var.tfc_project_name}:workspace:${var.tfc_workspace_name}:run_phase:apply"
  }

  user_claim = "terraform_full_workspace"
  role_type  = "jwt"
  token_ttl  = 1200
}

# Vault policy for plan role
resource "vault_policy" "tfc_plan_policy" {
  name = "${var.tfc_workspace_name}-tfc-plan-policy"

  policy = var.vault_plan_policy
}

# Vault Policy for apply role
resource "vault_policy" "tfc_apply_policy" {
  name = "${var.tfc_workspace_name}-tfc-apply-policy"

  policy = var.vault_apply_policy
}

resource "tfe_workspace" "consumer_workspace" {
  name                = var.tfc_workspace_name
  organization        = var.tfc_organization_name
  project_id          = data.tfe_project.vault-dynamic-provider.id
  execution_mode      = "remote"
#   working_directory   = "vault-consumer-workspace"
#   vcs_repo {
#     identifier     = "steven-whaley/vault-dynamic-provider-creds"
#     oauth_token_id = data.tfe_oauth_client.github.oauth_token_id
#   }
}

resource "tfe_variable" "vault_provider_auth" {
  for_each = var.vault_workspace_variables
  
  key          = each.key
  value        = each.value
  category     = "env"
  workspace_id = tfe_workspace.consumer_workspace.id
}

resource "tfe_variable" "tfc_plan_role" {  
  key          = "TFC_VAULT_PLAN_ROLE"
  value        = "${var.tfc_workspace_name}-vault-plan-role"
  category     = "env"
  workspace_id = tfe_workspace.consumer_workspace.id
}

resource "tfe_variable" "tfc_apply_role" {
  key          = "TFC_VAULT_APPLY_ROLE"
  value        = "${var.tfc_workspace_name}-vault-apply-role"
  category     = "env"
  workspace_id = tfe_workspace.consumer_workspace.id
}