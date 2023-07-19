output "pki_int_path" {
    value = vault_mount.pki_int.path
    description = "The path of the intermediate PKI mount"
}

output "pki_int_role" {
    value = vault_pki_secret_backend_role.role.name
    description = "The role created on the intermediate PKI mount"
}

output "kv_mount" {
    value = vault_mount.kvv2.path
    description = "The mount path of the kv secret engine"
}

output "kv_secret" {
    value = vault_kv_secret_v2.database_credentials.name
    description = "The name of the KV secret we store the database credentials in"
}

output "aws_backend" {
    value = vault_aws_secret_backend.vault_aws.path
    description = "Path for the AWS Secret Backend"
}

output "aws_plan_role" {
    value = vault_aws_secret_backend_role.tf_plan_role.name
    description = "Name of AWS secret engine role"
}

output "aws_apply_role" {
    value = vault_aws_secret_backend_role.tf_apply_role.name
    description = "Name of AWS secret engine role"
}

output "ec2_subnet_id" {
    value = module.vault-dynamic-provider-vpc.public_subnets    
    description = "Subnet ID for the public subnet to use for the EC2 instance"
}

output "vpc_id" {
    value = module.vault-dynamic-provider-vpc.vpc_id    
    description = "VPC ID"
}

output "database_address" {
    value = aws_db_instance.postgres.address
    description = "Address of the RDS instance"
}

output "database_port" {
    value = aws_db_instance.postgres.port
    description = "Port of the RDS instance"
}