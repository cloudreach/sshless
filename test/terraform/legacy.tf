



data "template_file" "user_data_onprem-1" {
  template = "${file("user_data.tpl")}"

  vars {
    hostname           = "legacy-1"
    region             = "${var.region}"
    activation_code    = "${aws_ssm_activation.ssm_activation-1.activation_code}"
    activation_id      = "${aws_ssm_activation.ssm_activation-1.id}"
  }
}

resource "aws_instance" "legacy-1" {
  count = 1
  ami                    = "${data.aws_ami.amazon_linux.id}"
  instance_type          = "t2.micro"
  subnet_id              = "${element(aws_subnet.public.*.id, 0)}"
  user_data              = "${data.template_file.user_data_onprem-1.rendered}"
  vpc_security_group_ids = ["${aws_security_group.sg_base.id}"]
  tags = "${merge(
            map("Name", "legacy-1"),
            map("Owner", "demo"),
            map("Role", "legacy"),
            map("Purpose", "sshless-onprem")
            )}"
}




data "template_file" "user_data_onprem-2" {
  template = "${file("user_data.tpl")}"

  vars {
    hostname           = "legacy-2"
    region             = "${var.region}"
    activation_code    = "${aws_ssm_activation.ssm_activation-2.activation_code}"
    activation_id      = "${aws_ssm_activation.ssm_activation-2.id}"
  }
}

resource "aws_instance" "legacy-2" {
  count = 1
  ami                    = "${data.aws_ami.amazon_linux.id}"
  instance_type          = "t2.micro"
  subnet_id              = "${element(aws_subnet.public.*.id, 0)}"
  user_data              = "${data.template_file.user_data_onprem-2.rendered}"
  vpc_security_group_ids = ["${aws_security_group.sg_base.id}"]
  tags = "${merge(
            map("Name", "legacy-2"),
            map("Owner", "demo"),
            map("Role", "legacy"),
            map("Purpose", "sshless-onprem")
            )}"
}
