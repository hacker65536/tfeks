data "aws_iam_policy_document" "assume_role_policy_aws" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.caller_id.account_id]
    }
  }
}

resource "aws_iam_role" "eksmasterrole" {
  name               = "test_eksmaster_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_policy_aws.json

  tags = {
    tag-key = "tag-value"
  }
}
