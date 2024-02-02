data "aws_iam_policy_document" "bastion_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com", "ssm.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "rds_permissions" {
  statement {
    sid = "RDSFullAccess"
    actions = [
      "rds:*",
    ]
    resources = ["*"]
  }
}


resource "aws_iam_role" "bastion_role" {
  name               = "${local.naming_prefix}-bastion"
  assume_role_policy = data.aws_iam_policy_document.bastion_policy.json

  inline_policy {
    name   = "rds-full-access"
    policy = data.aws_iam_policy_document.rds_permissions.json
  }
}

resource "aws_iam_role_policy_attachment" "bastion_policy_attachment" {
  role       = "${aws_iam_role.bastion_role.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_instance_profile" "bastion_profile" {
  name = "instance-connect"
  role = "${aws_iam_role.bastion_role.id}"
}

resource "aws_security_group" "bastion_host" {
  vpc_id      = aws_vpc.phi_api.id
  name_prefix = "instance_connect"
  description = "allow ssh"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_list
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion_host" {
  ami                         = var.bastion_ami_id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_web_subnet_cidrs[0].id
  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.bastion_host.id]

  iam_instance_profile = aws_iam_instance_profile.bastion_profile.name
  
  tags = {
    Name = "${local.naming_prefix}-bastion-host"
  }

  user_data = <<EOF
#!/bin/bash
yum update -y -q
yum install ec2-instance-connect
EOF
}
