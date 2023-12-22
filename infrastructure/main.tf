provider "aws" {
  region     = "us-east-1"
}

resource "aws_key_pair" "aws_keypair" {
  key_name   = "terraform_test"
  public_key = "${file(var.ssh_key_public)}"
}

resource "aws_security_group" "server_sg" {
  vpc_id = "vpc-05df269ff45faede9"

  # SSH ingress access for provisioning
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH access for provisioning"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow access to http servers"
  }
  ingress {
     from_port   = 0
     to_port     = 65535
     protocol    = "tcp"
   
     security_groups = ["sg-0e240370e13bf3320"]
 }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "c10k_server" {
  ami                         = "ami-079db87dc4c10ac91"
  instance_type               = "t2.micro"
  subnet_id                   = "subnet-086f15569e4d1d06f"
  vpc_security_group_ids      = ["${aws_security_group.server_sg.id}"]
  key_name                    = "${aws_key_pair.aws_keypair.key_name}"
  associate_public_ip_address = true
  count                       = 1

  #provisioner "remote-exec" {
    # Install Python for Ansible
   # inline = ["sudo apt install python3"]

    #connection {
     # type        = "ssh"
      #user        = "ubuntu"
     # host = "${self.public_ip}"
     # private_key = "${file("${aws_key_pair.aws_keypair.key_name}")}"
    #}
 # }

 # provisioner "local-exec" {
  #  command = "ansible-playbook -u ubuntu -i '${self.public_ip},' --private-key ${file("${var.ssh_key_private}")} -T 300 provision.yml" 
 # }
}
