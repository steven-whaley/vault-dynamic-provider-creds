# Create auth backend for TFC to use to authenticate to Vault
resource "vault_jwt_auth_backend" "tfc_jwt" {
  path               = "tfc_jwt"
  type               = "jwt"
  oidc_discovery_url = var.tfc_hostname
  bound_issuer       = var.tfc_hostname
}

module "vault-consumer-workspace" {
    source = "./workspace-setup"

    tfc_organization_name = var.tfc_organization_name
    tfc_project_name = "Vault DPC - Instruqt"
    tfc_workspace_name = "vault-dpc-instruqt-consumer-workspace"

    vault_workspace_variables = {
         "TFC_VAULT_ADDR" = data.tfe_outputs.vault_dpc_instruqt_init.values.vault_pub_url
         "TFC_VAULT_AUTH_PATH" = vault_jwt_auth_backend.tfc_jwt.path
         "TFC_VAULT_NAMESPACE" = "admin"
         "TFC_VAULT_PROVIDER_AUTH" = "true"
    }

    vault_plan_policy = <<-EOT
# Allow tokens to query themselves
path "auth/token/lookup-self" {
  capabilities = ["read"]
}

# Allow tokens to renew themselves
path "auth/token/renew-self" {
    capabilities = ["update"]
}

# Allow tokens to revoke themselves
path "auth/token/revoke-self" {
    capabilities = ["update"]
}

path "kv/*" {
  capabilities = ["read", "list"]
}

path "${data.tfe_outputs.vault_dpc_instruqt_build.values.pki_int_path}/issue/${data.tfe_outputs.vault_dpc_instruqt_build.values.pki_int_role}" {
 capabilities = ["read", "list"]
}

path "${data.tfe_outputs.vault_dpc_instruqt_build.values.aws_backend}/creds/${data.tfe_outputs.vault_dpc_instruqt_build.values.aws_plan_role}" {
  capabilities = ["read", "list"]
}
EOT

    vault_apply_policy = <<-EOT
# Allow tokens to query themselves
path "auth/token/lookup-self" {
  capabilities = ["read"]
}

# Allow tokens to renew themselves
path "auth/token/renew-self" {
    capabilities = ["update"]
}

# Allow tokens to revoke themselves
path "auth/token/revoke-self" {
    capabilities = ["update"]
}

path "kv/*" {
  capabilities = ["read", "list"]
}

path "${data.tfe_outputs.vault_dpc_instruqt_build.values.pki_int_path}/issue/${data.tfe_outputs.vault_dpc_instruqt_build.values.pki_int_role}" {
 capabilities = ["read", "list", "create", "update"]
}

path "${data.tfe_outputs.vault_dpc_instruqt_build.values.aws_backend}/creds/${data.tfe_outputs.vault_dpc_instruqt_build.values.aws_apply_role}" {
  capabilities = ["read", "list"]
}
EOT
}

resource "tfe_variable" "aws_region" {
  key          = "region"
  value        = var.region
  category     = "terraform"
  workspace_id = module.vault-consumer-workspace.workspace_id
}

resource "tfe_variable" "vault_backed_aws" {
  key          = "TFC_VAULT_BACKED_AWS_AUTH"
  value        = "true"
  category     = "env"
  workspace_id = module.vault-consumer-workspace.workspace_id
}

resource "tfe_variable" "vault_backed_aws_type" {
  key          = "TFC_VAULT_BACKED_AWS_AUTH_TYPE"
  value        = "iam_user"
  category     = "env"
  workspace_id = module.vault-consumer-workspace.workspace_id
}

resource "tfe_variable" "vault_backed_aws_plan_role" {
  key          = "TFC_VAULT_BACKED_AWS_PLAN_VAULT_ROLE"
  value        = data.tfe_outputs.vault_dpc_instruqt_build.values.aws_plan_role
  category     = "env"
  workspace_id = module.vault-consumer-workspace.workspace_id
}

resource "tfe_variable" "vault_backed_aws_run_role" {
  key          = "TFC_VAULT_BACKED_AWS_APPLY_VAULT_ROLE"
  value        = data.tfe_outputs.vault_dpc_instruqt_build.values.aws_apply_role
  category     = "env"
  workspace_id = module.vault-consumer-workspace.workspace_id
}

resource "tfe_variable" "vault_backed_aws_path" {
  key          = "TFC_VAULT_BACKED_AWS_MOUNT_PATH"
  value        = data.tfe_outputs.vault_dpc_instruqt_build.values.aws_backend
  category     = "env"
  workspace_id = module.vault-consumer-workspace.workspace_id
}