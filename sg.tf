# Create a Security Group for the VPC
resource "aws_security_group" "sg_vpc" {
  name        = "sg_sharkblog_vpc"
  description = "Allow traffic for Shark Blog"
  vpc_id      = aws_vpc.sharkblog_vpc.id

  # Add inbound rules
  # Add a rule for HTTP
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.CIDR_BLOCK]
  }

  # Add a rule for HTTPS
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.CIDR_BLOCK]
  }

  # Add a rule for SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.CIDR_BLOCK]
  }

  # Add an outbound rule
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.CIDR_BLOCK]
  }
  tags = {
    Name = "sg-sharkblog-vpc"
  }
}

resource "aws_security_group" "allow_ssh" {
  name        = "allow_sharkblog_ssh"
  description = "Allow SSH traffic for Shark Blog"
  vpc_id      = aws_vpc.sharkblog_vpc.id

  ingress {
    description      = "Allow SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_sharkblog_ssh"
  }
}

resource "aws_security_group" "allow_ec2_aurora" {
  name        = "allow_sharkblog_ec2_aurora"
  description = "Allow EC2 to Aurora traffic for Shark Blog"
  vpc_id      = aws_vpc.sharkblog_vpc.id

  ingress {
    description      = "Allow EC2 to Aurora"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 3306
    to_port          = 3306
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_sharkblog_ec2_aurora"
  }
}

resource "aws_security_group" "allow_aurora_access" {
  name        = "allow_sharkblog_aurora_access"
  description = "Allow EC2 to Aurora for Shark Blog"
  vpc_id      = aws_vpc.sharkblog_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    # security_groups = [aws_security_group.allow_ssh.id] 
  }

  tags = {
    Name = "sharkblog-allow-aurora-MySQL"
  }
}
