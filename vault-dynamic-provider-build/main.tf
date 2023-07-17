resource "random_string" "db_password" {
    length = 12
    special = false
}

# Create VPC for AWS resources
module "vault-dynamic-provider-vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "vault-dynamic-provider-vpc"

  cidr = "10.10.0.0/16"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)

  private_subnets = ["10.10.11.0/24", "10.10.12.0/24"]
  public_subnets  = ["10.10.21.0/24"]

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true
}

### Create peering connection to Vault HVN 
resource "hcp_aws_network_peering" "vault" {
  hvn_id          = data.tfe_outputs.vault_dynamic_provider_init.values.hvn_id
  peering_id      = "vault-dynamic-provider-cluster"
  peer_vpc_id     = module.vault-dynamic-provider-vpc.vpc_id
  peer_account_id = module.vault-dynamic-provider-vpc.vpc_owner_id
  peer_vpc_region = data.aws_arn.peer_vpc.region
}

resource "aws_vpc_peering_connection_accepter" "peer" {
  vpc_peering_connection_id = hcp_aws_network_peering.vault.provider_peering_id
  auto_accept               = true
}

resource "time_sleep" "wait_60s" {
  depends_on = [
    aws_vpc_peering_connection_accepter.peer
  ]
  create_duration = "60s"
}

resource "aws_vpc_peering_connection_options" "dns" {
  depends_on = [
    time_sleep.wait_60s
  ]
  vpc_peering_connection_id = hcp_aws_network_peering.vault.provider_peering_id
  accepter {
    allow_remote_vpc_dns_resolution = true
  }
}

resource "hcp_hvn_route" "hcp_vault" {
  hvn_link         = data.tfe_outputs.vault_dynamic_provider_init.values.hvn_self_link
  hvn_route_id     = "vault-to-internal-clients"
  destination_cidr = module.vault-dynamic-provider-vpc.vpc_cidr_block
  target_link      = hcp_aws_network_peering.vault.self_link
}

resource "aws_route" "vault" {
  for_each = {
    for idx, rt_id in module.vault-dynamic-provider-vpc.private_route_table_ids : idx => rt_id
  }
  route_table_id            = each.value
  destination_cidr_block    = data.tfe_outputs.vault_dynamic_provider_init.values.hvn_cidr
  vpc_peering_connection_id = hcp_aws_network_peering.vault.provider_peering_id
}

# Create AWS RDS Database
resource "aws_db_subnet_group" "postgres" {
  name       = "vault-dynamic-provider-group"
  subnet_ids = module.vault-dynamic-provider-vpc.private_subnets
}

resource "aws_db_instance" "postgres" {
  allocated_storage      = 10
  db_name                = "postgres"
  engine                 = "postgres"
  engine_version         = "12.15"
  allow_major_version_upgrade = false
  auto_minor_version_upgrade = false
  instance_class         = "db.t3.micro"
  username               = var.db_admin_name
  password               = random_string.db_password.result
  db_subnet_group_name   = aws_db_subnet_group.postgres.name
  skip_final_snapshot    = true
  vpc_security_group_ids = [module.rds-sec-group.security_group_id]
}

#RDS Security Group
module "rds-sec-group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = "rds-sec-group"
  description = "Allow Access from HCP Vault to Database Endpoint"
  vpc_id      = module.vault-dynamic-provider-vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      rule        = "postgresql-tcp"
      cidr_blocks = "${data.tfe_outputs.vault_dynamic_provider_init.values.hvn_cidr},${module.vault-dynamic-provider-vpc.vpc_cidr_block}"
    }
  ]
}

# Create Vault KV Secrets Engine
resource "vault_mount" "kvv2" {
  path        = "kv"
  type        = "kv"
  options     = { version = "2" }
  description = "KV Version 2 secret engine mount"
}

resource "vault_kv_secret_backend_v2" "example" {
  mount        = vault_mount.kvv2.path
  max_versions = 5
}

resource "vault_kv_secret_v2" "database_credentials" {
  mount               = vault_mount.kvv2.path
  name                = "database_credentials"
  cas                 = 1
  delete_all_versions = true
  data_json = jsonencode(
    {
      admin_username = var.db_admin_name,
      admin_password = random_string.db_password.result
    }
  )
}

# Create and configure PKI Secrets Engine
# Create the Root CA
resource "vault_mount" "pki_root" {
  path = "pki_root"
  type = "pki"
  description = "SWCloudlab Root CA"
}

resource "vault_pki_secret_backend_root_cert" "root_ca" {
  backend               = vault_mount.pki_root.path
  type                  = "internal"
  common_name           = "SW Cloudlab Root CA"
  ttl                   = 31557600
  format                = "pem"
  private_key_format    = "der"
  key_type              = "rsa"
  key_bits              = 4096
  exclude_cn_from_sans  = true
  ou                    = "Vault Dynamic Provider OU"
  organization          = "swcloublab"
}

resource "vault_pki_secret_backend_config_urls" "root_urls" {
  backend = vault_mount.pki_root.path
  issuing_certificates = [
    "http://127.0.0.1:8200/v1/pki/ca",
  ]
}

# Create Intermediate CA
resource "vault_mount" "pki_int" {
  path = "pki_int"
  type = "pki"
  description = "SWCloudLab Intermediate CA"
}

resource "vault_pki_secret_backend_intermediate_cert_request" "pki_int" {
  depends_on = [ vault_mount.pki_root ]
  backend     = vault_mount.pki_int.path
  type        = "internal"
  common_name = "SWCloudlab Intermediate CA"
}

resource "vault_pki_secret_backend_root_sign_intermediate" "int" {
  depends_on           = [ vault_pki_secret_backend_intermediate_cert_request.pki_int ]
  backend              = vault_mount.pki_root.path
  csr                  = vault_pki_secret_backend_intermediate_cert_request.pki_int.csr
  ttl = 7889400
  common_name          = "SWCloudlab Intermediate CA"
  ou                   = "Vault Dynamic Provider Lab"
  organization         = "swcloudlab"
}

resource "vault_pki_secret_backend_intermediate_set_signed" "pki_int" {
  backend     = vault_mount.pki_int.path
  certificate = vault_pki_secret_backend_root_sign_intermediate.int.certificate
}

resource "vault_pki_secret_backend_role" "role" {
  backend          = vault_mount.pki_int.path
  name             = "server"
  ttl              = 2592000
  allow_ip_sans    = true
  key_type         = "rsa"
  key_bits         = 4096
  allowed_domains  = ["swcloudlab.net", "local"]
  allow_subdomains = true
}

# Create and Configure AWS Secrets Engine
#Create policy for AWS dynamic creds read
resource "vault_policy" "aws" {
  name   = "aws"
  policy = <<EOT
    path "aws/creds/vault-demo-iam-user"
    {
        capabilities = ["read"]
    }
    EOT
}

resource "aws_iam_user" "vault_mount_user" {
  name                 = "demo-${local.my_email}"
  permissions_boundary = data.aws_iam_policy.demo_user_permissions_boundary.arn
  force_destroy        = true
}

resource "aws_iam_user_policy_attachment" "vault_mount_user" {
  user       = aws_iam_user.vault_mount_user.name
  policy_arn = data.aws_iam_policy.demo_user_permissions_boundary.arn
}

resource "aws_iam_access_key" "vault_mount_user" {
  user = aws_iam_user.vault_mount_user.name
}

resource "vault_aws_secret_backend" "vault_aws" {
  access_key        = aws_iam_access_key.vault_mount_user.id
  secret_key        = aws_iam_access_key.vault_mount_user.secret
  description       = "Demo of the AWS secrets engine"
  region            = var.region
  username_template = "{{ if (eq .Type \"STS\") }}{{ printf \"${aws_iam_user.vault_mount_user.name}-%s-%s\" (random 20) (unix_time) | truncate 32 }}{{ else }}{{ printf \"${aws_iam_user.vault_mount_user.name}-vault-%s-%s\" (unix_time) (random 20) | truncate 60 }}{{ end }}"
}

resource "vault_aws_secret_backend_role" "vault_role_iam_user_credential_type" {
  backend                  = vault_aws_secret_backend.vault_aws.path
  credential_type          = "iam_user"
  name                     = "vault-demo-iam-user"
  permissions_boundary_arn = data.aws_iam_policy.demo_user_permissions_boundary.arn
  policy_document          = data.aws_iam_policy_document.vault_dynamic_iam_user_policy.json
}
