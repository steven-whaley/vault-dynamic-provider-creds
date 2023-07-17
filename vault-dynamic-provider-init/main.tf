# Create HVN for Vault
resource "hcp_hvn" "vault-dynamic-provider-hvn" {
  hvn_id         = "vault-dynamic-provider-demo-hvn"
  cloud_provider = "aws"
  region         = var.region
  cidr_block     = "172.16.1.0/24"
}

# Create HCP Vault Cluster
resource "hcp_vault_cluster" "vault-dynamic-provider-cluster" {
  cluster_id      = "vault-dynamic-provider-cluster"
  hvn_id          = hcp_hvn.vault-dynamic-provider-hvn.hvn_id
  tier            = "dev"
  public_endpoint = true
}

# Create Admin token for HCP Vault Cluster
resource "hcp_vault_cluster_admin_token" "tfc-vault-token" {
  cluster_id = hcp_vault_cluster.vault-dynamic-provider-cluster.cluster_id
}