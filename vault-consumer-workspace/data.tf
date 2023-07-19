data "hcp_packer_image" "myapp" {
  bucket_name    = "vault-dpc-instruqt-myapp"
  channel        = "latest"
  cloud_provider = "aws"
  region         = "us-west-2"
}

data "tfe_outputs" "vault_dpc_instruqt_build" {
  organization = "swhashi"
  workspace    = "vault-dpc-instruqt-build"
}

data "vault_kv_secret_v2" "db_creds" {
  mount = data.tfe_outputs.vault_dpc_instruqt_build.values.kv_mount
  name = data.tfe_outputs.vault_dpc_instruqt_build.values.kv_secret
}