resource "aws_iam_role" "ec2-instance-role" {
  name = "sshless-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ssm-policy" {
    role       = "${aws_iam_role.ec2-instance-role.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy_attachment" "s3-policy" {
    role       = "${aws_iam_role.ec2-instance-role.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}


//  Create a instance profile for the role.
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name  = "sshless-instance-profile"
  role = "${aws_iam_role.ec2-instance-role.name}"
}








resource "aws_iam_role" "sshless-role-onprem" {
  name = "sshless-role-onprem"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "ssm.amazonaws.com"
            },
            "Effect": "Allow"
        }
    ]
}
EOF
}


resource "aws_iam_role_policy_attachment" "ssm-policy-onprem" {
    role       = "${aws_iam_role.sshless-role-onprem.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy_attachment" "s3-policy-onprem" {
    role       = "${aws_iam_role.sshless-role-onprem.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
