variable "user_data" {
  description = "ec2 user_data"
  default = <<EOF
#!/bin/bash
sudo start amazon-ssm-agent
EOF
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "amzn-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }
}


resource "aws_security_group" "sg_base" {
  name        = "sshless-sg"
  description = "sshless-sg"
  vpc_id      = "${aws_vpc.this.id}"

  ingress {
    from_port = 8
    to_port = 0
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}



resource "aws_instance" "web" {
  count = 2
  ami                    = "${data.aws_ami.amazon_linux.id}"
  instance_type          = "t2.micro"
  subnet_id              = "${element(aws_subnet.public.*.id, 0)}"
  user_data              = "${var.user_data}"
  vpc_security_group_ids = ["${aws_security_group.sg_base.id}"]
  iam_instance_profile   = "${aws_iam_instance_profile.ec2_instance_profile.name}"
  tags = "${merge(
            map("Name", format("%s-%d", "web", count.index+1)),
            map("Owner", "demo"),
            map("Role", "web"),
            map("Purpose", "sshless")
            )}"
}

resource "aws_instance" "app" {
  count = 2
  ami                    = "${data.aws_ami.amazon_linux.id}"
  instance_type          = "t2.micro"
  subnet_id              = "${element(aws_subnet.public.*.id, 0)}"
  user_data              = "${var.user_data}"
  vpc_security_group_ids = ["${aws_security_group.sg_base.id}"]
  iam_instance_profile   = "${aws_iam_instance_profile.ec2_instance_profile.name}"
  tags = "${merge(
            map("Name", format("%s-%d", "app", count.index+1)),
            map("Owner", "demo"),
            map("Role", "app"),
            map("Purpose", "sshless")
            )}"
}
