
locals {
  vpc_id           = "vpc-05df269ff45faede9"
  ssh_user         = "ubuntu"
  key_name         = "ADMIN_KEYPAIR"
  private_key_path = "./ADMIN_KEYPAIR.pem"
}
variable "privatekey" {
  description = "AWS EC2 Key Pair that need to be associated with EC2 Instance"
  type = string
  default = "ADMIN_KEYPAIR"
}

provider "aws" {
  region = "us-east-1"
}
resource "aws_key_pair" "ADMIN_KEYPAIR" {
  key_name   = "ADMIN_KEYPAIR"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCchMv4dNSFXbpGgeYXy+pqWWJxES6r+tPVwVSyCwtMjx/lUQrp/KTRFE9XBneT5Kts9KWWaoHYTghEK8eHnWkzphq4now7Xgosdq+/oTs/ju3bdZkWBhU1tvfuXxZTyr8yP6rFkNl74OeV5OGYm+Plssd6GkFnwemOIAHohbFhmqL2Yv4gRTFxnA4J2PsTrQ0F/UyPR1QcYdI3a+CfuWRDk3z2aSdDCsF3y8DvhyT4fsaW3ZOuxZe46zfV+S0QzTOIB/8NLHLHxJKIZ9fy2hiCCp3aTDaKqAZRNEnBP4kd9cuI0C2U3WqNnyfuJHcKZomPWeSmsKmWAskSxrS0L8a2SmJJmXAl+ZGJ3KjS+r/TrBAjzzlff0GGadMZacbQ4th9abz+0BgSSKqgvnMeVJpkpTd6r1GG4k+rGxR+lD+D6IcR30ZvgfFBEQsK6+hod23jECK7f8nvYDQ2UMI96f4Hir9ZgGwfwv5U+z4fRNSy444r4IOmgKy79BQPNtLHKg0= root@ip-172-31-53-169"


}

resource "aws_security_group" "nginx" {
  name   = "nginx_access"
  vpc_id = local.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nginx" {
  ami                         = "ami-079db87dc4c10ac91"
  subnet_id                   = "subnet-086f15569e4d1d06f"
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.nginx.id]
  key_name                    = "ADMIN_KEYPAIR"

  provisioner "remote-exec" {
    inline = ["echo 'build ssh connection' "]
    connection {
      host        = self.public_ip
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("./ADMIN_KEYPAIR.pem")
    }

  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ${self.public_ip}, --private-key ${var.privatekey} playbook.yaml"
  }

}











