locals {
  near_mainnet_bucket_arn = "arn:aws:s3:::near-lake-data-mainnet"
  near_testnet_bucket_arn = "arn:aws:s3:::near-lake-data-testnet"
}

data "aws_iam_policy_document" "near-lake-data-r" {
  statement {
    actions = [
      "s3:GetObject",
    ]

    resources = [
      "${local.near_mainnet_bucket_arn}/*",
      "${local.near_testnet_bucket_arn}/*",
    ]
  }

  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      local.near_mainnet_bucket_arn,
      local.near_testnet_bucket_arn,
    ]
  }
}

resource "aws_iam_policy" "near-lake-data-r" {
  policy = data.aws_iam_policy_document.near-lake-data-r.json
}

resource "aws_iam_role_policy_attachment" "near-lake-data-r" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.near-lake-data-r.arn
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "this" {
  name = "${var.name}"

  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.name}"

  role = aws_iam_role.this.name
}
