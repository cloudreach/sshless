



data "template_file" "user_data_azure-1" {
  template = "${file("user_data.tpl")}"

  vars {
    hostname           = "azure-1"
    region             = "${var.region}"
    activation_code    = "${aws_ssm_activation.ssm_activation-a1.activation_code}"
    activation_id      = "${aws_ssm_activation.ssm_activation-a1.id}"
  }
}

resource "aws_instance" "azure-1" {
  count = 1
  ami                    = "${data.aws_ami.amazon_linux.id}"
  instance_type          = "t2.micro"
  subnet_id              = "${element(aws_subnet.public.*.id, 0)}"
  user_data              = "${data.template_file.user_data_azure-1.rendered}"
  vpc_security_group_ids = ["${aws_security_group.sg_base.id}"]
  tags = "${merge(
            map("Name", "azure-1"),
            map("Owner", "demo"),
            map("Role", "azure"),
            map("Purpose", "sshless-azure")
            )}"
}
