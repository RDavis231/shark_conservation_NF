locals {
  # Name of the EC2 instance
  name  = "shark_conservation_ec2"
  owner = "shark_team"
}

### Select the Amazon Linux 2 AMI (Free Tier Eligible)
data "aws_ami" "latest_linux_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

### Create an EC2 instance for WordPress
resource "aws_instance" "shark_conservation_instance" {
  ami                         = data.aws_ami.latest_linux_ami.id
  instance_type               = "t2.micro"  # Free Tier Eligible
  availability_zone           = "us-east-1a"
  associate_public_ip_address = true
  key_name                    = "shark-conservation-key"
  vpc_security_group_ids      = [aws_security_group.shark_conservation_sg.id]
  subnet_id                   = aws_subnet.shark_conservation_public_1.id
  iam_instance_profile        = "shark_conservation_ec2_profile"
  count                       = 1

  tags = {
    Name = local.name
    Owner = local.owner
  }

  # User data for automatic WordPress setup
  user_data = "${base64encode(data.template_file.ec2_user_data.rendered)}"

  provisioner "local-exec" {
    command = "echo Instance ID = ${self.id}, Public IP = ${self.public_ip}, AMI ID = ${self.ami} >> ec2_metadata.txt"
  }
}

### User Data for WordPress Setup
data "template_file" "ec2_user_data" {
  template = file("userdata.tpl")
}
