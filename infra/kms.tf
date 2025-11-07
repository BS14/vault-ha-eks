module "kms" {
  source                  = "terraform-aws-modules/kms/aws"
  version                 = "4.1.1"
  description             = "Used for auto-unseal for hashicorp vault."
  key_usage               = "ENCRYPT_DECRYPT"
  enable_key_rotation     = true
  rotation_period_in_days = 90
}

# IRSA Role for vault for accessing kms keys.

# Define the IAM policy document for KMS permissions
data "aws_iam_policy_document" "vault_kms" {
  statement {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
      "kms:ListGrants",
      "kms:CreateGrant",
      "kms:RevokeGrant"
    ]
    resources = [
      module.kms.key_arn
    ]
  }
}

# Create the IAM policy from the document
resource "aws_iam_policy" "vault_kms" {
  name        = "${module.eks.cluster_name}-vault-kms"
  description = "Allows Vault to use the KMS key for auto-unseal"
  policy      = data.aws_iam_policy_document.vault_kms.json
}

# Use the module to create the IRSA role
module "vault_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "6.2.3"

  role_name = "${module.eks.cluster_name}-vault-kms-role"

  policy_arns_to_attach = [
    aws_iam_policy.vault_kms.arn
  ]

  oidc_provider_arn = module.eks.oidc_provider_arn

  service_accounts = [
    "${var.vault_namespace}:${var.vault_service_account_name}"
  ]
  depends_on = [module.eks, module.kms]
}
