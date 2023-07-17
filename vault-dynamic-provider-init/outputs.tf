output "vault_pub_url" {
  description = "The public URL of the HCP Vault cluster"
  value       = hcp_vault_cluster.vault-dynamic-provider-cluster.vault_public_endpoint_url
}

output "vault_priv_url" {
  description = "The private URL of the HCP Vault Cluster within the AWS VPC "
  value       = hcp_vault_cluster.vault-dynamic-provider-cluster.vault_private_endpoint_url
}

output "vault_token" {
  description = "The Vault admin token used to configure the Vault provider in the boundary-demo-eks workspace"
  value       = hcp_vault_cluster_admin_token.tfc-vault-token.token
  sensitive   = true
}

output "vault_cluster_id" {
  description = "The cluster id of the HCP Vault Cluster"
  value       = hcp_vault_cluster.vault-dynamic-provider-cluster.cluster_id
}

output "hvn_id" {
  value = hcp_hvn.vault-dynamic-provider-hvn.hvn_id
}

output "hvn_self_link" {
  value = hcp_hvn.vault-dynamic-provider-hvn.self_link
}

output "hvn_cidr" {
  value = hcp_hvn.vault-dynamic-provider-hvn.cidr_block
}