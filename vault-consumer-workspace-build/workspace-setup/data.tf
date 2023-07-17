data "tfe_project" "vault-dynamic-provider" {
  organization = var.tfc_organization_name
  name         = var.tfc_project_name
}

#Build Consumer Workspace
# data "tfe_oauth_client" "github" {
#   organization     = var.tfc_organization_name
#   service_provider = "github"
# }