locals {
  # The name of the EC2 instance
  name = "shark_conservation_ec2"
  owner = "rd"
}

### Select the newest AMI

data "aws_ami" "latest_linux_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*x86_64"]
  }
}

### Create an EC2 instance

resource "aws_instance" "instance" {
  #ami                         = data.aws_ami.latest_linux_ami.id
  ami = var.AMIs[var.AWS_REGION]
  instance_type               = "t2.micro"
  availability_zone           = "us-east-1a"
  associate_public_ip_address = true
  key_name                    = "sharkconservation"
  vpc_security_group_ids      = [aws_vpc.shark_conservation_vpc.id]
  subnet_id                   = aws_vpc.shark_conservation_vpc.id
  iam_instance_profile        = "sharkconservation_ec2"
  count = 1
  tags = {
    Name = local.name
  }
  #user_data = file("userdata.sh")
  user_data = "${base64encode(data.template_file.ec2userdatatemplate.rendered)}"

  provisioner "local-exec" {
    command = "echo Instance Type = ${self.instance_type}, Instance ID = ${self.id}, Public IP = ${self.public_ip}, AMI ID = ${self.ami} >> metadata"
  }
}


data "template_file" "ec2userdatatemplate" {
  template = "${file("userdata.tpl")}"
}

output "ec2rendered" {
  value = "${data.template_file.ec2userdatatemplate.rendered}"
}

output "public_ip" {
  value = aws_instance.instance[0].public_ip
}
