module "kms" {
  source                  = "terraform-aws-modules/kms/aws"
  version                 = "4.1.1"
  description             = "Used for auto-unseal for hashicorp vault."
  key_usage               = "ENCRYPT_DECRYPT"
  enable_key_rotation     = true
  rotation_period_in_days = 90
}

# Pod-identity.

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
  }
}

resource "aws_iam_role" "role_vault_kms" {
  name               = "${module.eks.cluster_name}-vault-kms-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

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
resource "aws_iam_policy" "policy_vault_kms" {
  name        = "${module.eks.cluster_name}-vault-kms-policy"
  description = "Allows Vault to use the KMS key for auto-unseal."
  policy      = data.aws_iam_policy_document.vault_kms.json
}

resource "aws_iam_role_policy_attachment" "attach_kms_policy" {
  policy_arn = aws_iam_policy.policy_vault_kms.arn
  role       = aws_iam_role.role_vault_kms.name
}

resource "aws_eks_pod_identity_association" "kms_pod_identity_association" {
  cluster_name    = module.eks.cluster_name
  namespace       = var.vault_namespace
  service_account = var.vault_service_account_name
  role_arn        = aws_iam_role.role_vault_kms.arn
}
