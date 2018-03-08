data "aws_caller_identity" "current" {}


resource "aws_iam_role" "sshless-role-webrole" {
  name = "sshless-role-webrole"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
              "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
            },
            "Effect": "Allow"
        }
    ]
}
EOF
}


data "aws_iam_policy_document" "tag_filter" {
    statement {
        sid = "BasicSSM"
        effect = "Allow"
        actions = ["ssm:List*"]
        resources = ["arn:aws:ssm:*:*:*"]
    }

    statement {
        sid = "ReadAllDocument"
        effect = "Allow"
        actions = ["ssm:SendCommand"]
        resources = [
          "arn:aws:ssm:*:*:document/*",
          "arn:aws:ssm:*:*:document/sshless*"
        ]
    }

    statement {
        sid = "SendCommandTag"
        effect = "Allow"
        actions = [
          "ssm:SendCommand",

        ]
        resources = ["arn:aws:ec2:*:*:instance/*"]
        condition {
            test = "StringLike"
            variable = "ssm:resourceTag/Role"
            values = ["web"]
        }
    }
}

resource "aws_iam_policy" "web-only" {
  name        = "web-app-only"
  path        = "/"
  description = "Allows run command on Role web only"
  policy = "${data.aws_iam_policy_document.tag_filter.json}"
}




resource "aws_iam_role_policy_attachment" "ssm-policy-webonly" {
    role       = "${aws_iam_role.sshless-role-webrole.name}"
    policy_arn = "${aws_iam_policy.web-only.arn}"
}


# service role
output "sshless-role-webrole" {
  value = "${aws_iam_role.sshless-role-webrole.arn}"
}
