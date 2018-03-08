
resource "aws_ssm_activation" "ssm_activation-1" {
  name               = "ssm_legacy-1"
  description        = "ssm_legacy-1"
  iam_role           = "${aws_iam_role.sshless-role-onprem.id}"
  registration_limit = "1"
  depends_on         = ["aws_iam_role_policy_attachment.ssm-policy-onprem"]
}

resource "aws_ssm_activation" "ssm_activation-2" {
  name               = "ssm_legacy-2"
  description        = "ssm_legacy-2"
  iam_role           = "${aws_iam_role.sshless-role-onprem.id}"
  registration_limit = "1"
  depends_on         = ["aws_iam_role_policy_attachment.ssm-policy-onprem"]
}

resource "aws_ssm_activation" "ssm_activation-a1" {
  name               = "ssm_azure-1"
  description        = "ssm_azure-1"
  iam_role           = "${aws_iam_role.sshless-role-onprem.id}"
  registration_limit = "1"
  depends_on         = ["aws_iam_role_policy_attachment.ssm-policy-onprem"]
}


resource "aws_ssm_parameter" "example_parameter" {
  name  = "example.parameter"
  type  = "String"
  overwrite = true
  value = "I am an SSM parameter"
}


resource "aws_ssm_document" "web-sshd" {
  name          = "sshless_ssh_restart"
  document_type = "Command"

  content = <<DOC
  {
    "schemaVersion": "1.2",
    "description": "restart sshd service",
    "parameters": {

    },
    "runtimeConfig": {
      "aws:runShellScript": {
        "properties": [
          {
            "id": "0.aws:runShellScript",
            "runCommand": ["service sshd restart"]
          }
        ]
      }
    }
  }
DOC
}
